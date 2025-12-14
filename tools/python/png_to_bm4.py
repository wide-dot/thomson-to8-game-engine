#!/usr/bin/env python3
"""
Outil pour encoder une image PNG (indexée ou non, max 4 couleurs) en format BM4.
Format BM4: deux fichiers binaires (RAMA et RAMB) pour encoder 4 couleurs.
- RAMA contient le bit de poids faible (LSB) de chaque pixel
- RAMB contient le bit de poids fort (MSB) de chaque pixel
- 8 pixels par octet (MSB first dans chaque octet)
- Les indices de palette 0-3 sont encodés comme suit:
  * Indice 0 (00) -> RAMA=0, RAMB=0
  * Indice 1 (01) -> RAMA=1, RAMB=0
  * Indice 2 (10) -> RAMA=0, RAMB=1
  * Indice 3 (11) -> RAMA=1, RAMB=1

Supporte les images indexées (mode P) et non indexées (RGB, RGBA, etc.).
Pour les images non indexées, les couleurs uniques sont automatiquement mappées aux indices 0-3.
"""

import sys
import argparse
from PIL import Image
import os
from image_stats import analyze_line_runs, print_run_statistics


def encode_png_to_bm4(input_path, output_base=None):
    """
    Encode une image PNG (indexée ou non, max 4 couleurs) en format BM4 (RAMA et RAMB).
    
    Args:
        input_path: Chemin vers l'image PNG d'entrée
        output_base: Chemin de base pour les fichiers de sortie (optionnel)
                    Les fichiers .rama.bin et .ramb.bin seront créés automatiquement
    
    Returns:
        tuple: (rama_data, ramb_data) - Les données binaires pour RAMA et RAMB
    """
    # Ouvrir l'image
    try:
        img = Image.open(input_path)
    except Exception as e:
        print(f"Erreur lors de l'ouverture de l'image: {e}", file=sys.stderr)
        sys.exit(1)
    
    print(f"Image originale: {img.width}x{img.height} pixels, mode {img.mode}")
    
    # Gérer les images indexées et non indexées
    if img.mode == 'P':
        # Image indexée: utiliser directement les indices de palette
        palette = img.getpalette()
        if palette is None:
            print("Erreur: L'image indexée n'a pas de palette", file=sys.stderr)
            sys.exit(1)
        
        # Compter les couleurs uniques utilisées (indices de palette)
        unique_colors = set(img.getdata())
        num_colors = len(unique_colors)
        
        if num_colors > 4:
            print(f"Erreur: L'image contient {num_colors} couleurs, mais seulement 4 sont autorisées", file=sys.stderr)
            sys.exit(1)
        
        if num_colors < 1:
            print("Erreur: L'image ne contient aucune couleur", file=sys.stderr)
            sys.exit(1)
        
        # Vérifier que seuls les indices 0-3 sont utilisés
        invalid_colors = [c for c in unique_colors if c not in [0, 1, 2, 3]]
        if invalid_colors:
            print(f"Erreur: L'image utilise des indices de palette invalides: {invalid_colors}", file=sys.stderr)
            print("Seuls les indices 0, 1, 2 et 3 sont autorisés", file=sys.stderr)
            sys.exit(1)
        
        # Obtenir les données des pixels (indices de palette 0-3)
        pixels = list(img.getdata())
        print(f"Image indexée: {num_colors} couleur(s) utilisée(s)")
        
    else:
        # Image non indexée: extraire les couleurs uniques et créer un mapping
        # Convertir en RGB si nécessaire (pour gérer RGBA, L, etc.)
        if img.mode != 'RGB':
            if img.mode == 'RGBA':
                # Créer une image blanche pour le fond et composer avec l'image RGBA
                rgb_img = Image.new('RGB', img.size, (255, 255, 255))
                rgb_img.paste(img, mask=img.split()[3])  # Utiliser le canal alpha comme masque
                img = rgb_img
            else:
                # Convertir les autres modes (L, LA, etc.) en RGB
                img = img.convert('RGB')
        
        # Extraire toutes les couleurs uniques
        pixel_data = list(img.getdata())
        unique_colors = set(pixel_data)
        num_colors = len(unique_colors)
        
        if num_colors > 4:
            print(f"Erreur: L'image contient {num_colors} couleurs, mais seulement 4 sont autorisées", file=sys.stderr)
            sys.exit(1)
        
        if num_colors < 1:
            print("Erreur: L'image ne contient aucune couleur", file=sys.stderr)
            sys.exit(1)
        
        # Créer un mapping des couleurs vers les indices 0-3
        # Trier les couleurs pour avoir un ordre déterministe
        sorted_colors = sorted(unique_colors)
        color_to_index = {color: idx for idx, color in enumerate(sorted_colors)}
        
        # Convertir les pixels en indices
        pixels = [color_to_index[color] for color in pixel_data]
        print(f"Image non indexée: {num_colors} couleur(s) unique(s) mappée(s) aux indices 0-{num_colors-1}")
    
    # Analyser les statistiques des séquences de pixels (runs)
    run_counter = analyze_line_runs(pixels, img.width, img.height)
    print_run_statistics(run_counter, len(pixels))
    
    # Extraire les bits LSB (RAMA) et MSB (RAMB) de chaque pixel
    # Pour un indice de palette n (0-3):
    # - RAMA = n & 1 (bit de poids faible)
    # - RAMB = (n >> 1) & 1 (bit de poids fort)
    rama_bits = [(pixel & 1) for pixel in pixels]
    ramb_bits = [((pixel >> 1) & 1) for pixel in pixels]
    
    # Calculer le nombre d'octets par ligne (arrondi vers le haut)
    import math
    bytes_per_line = math.ceil(img.width / 8)
    num_lines = img.height
    
    # Packer les bits en octets ligne par ligne, en complétant en fin de ligne
    def pack_bits_to_bytes_line_by_line(bits, width, height, bytes_per_line):
        """
        Packer une liste de bits en octets ligne par ligne.
        Complète les bits en fin de ligne pour former des octets complets (8 bits).
        
        Args:
            bits: Liste de bits (un par pixel)
            width: Largeur de l'image en pixels
            height: Hauteur de l'image en pixels
            bytes_per_line: Nombre d'octets par ligne (arrondi vers le haut)
        
        Returns:
            bytearray: Données binaires avec padding en fin de ligne
        """
        binary_data = bytearray()
        
        for y in range(height):
            line_start = y * width
            line_bits = bits[line_start:line_start + width]
            
            # Packer les bits de la ligne en octets
            for byte_idx in range(bytes_per_line):
                byte = 0
                bit_start = byte_idx * 8
                
                # Copier jusqu'à 8 bits (ou moins si fin de ligne)
                for bit_offset in range(8):
                    bit_pos = bit_start + bit_offset
                    if bit_pos < len(line_bits):
                        byte |= (line_bits[bit_pos] << (7 - bit_offset))
                    # Si on dépasse la ligne, les bits restants restent à 0 (padding)
                
                binary_data.append(byte)
        
        return binary_data
    
    rama_data = pack_bits_to_bytes_line_by_line(rama_bits, img.width, img.height, bytes_per_line)
    ramb_data = pack_bits_to_bytes_line_by_line(ramb_bits, img.width, img.height, bytes_per_line)
    
    # Ajouter le header: [nb_octets_par_ligne (8 bits), nb_lignes (8 bits)]
    header = bytearray([bytes_per_line, num_lines])
    
    # Préfixer le header aux données
    rama_data_with_header = header + rama_data
    ramb_data_with_header = header + ramb_data
    
    # Déterminer le chemin de base pour les fichiers de sortie
    if output_base is None:
        base_name = os.path.splitext(input_path)[0]
        # Si le nom se termine par .bm4, on enlève cette extension
        if base_name.endswith('.bm4'):
            base_name = base_name[:-4]
    else:
        base_name = output_base
    
    rama_path = base_name + '.rama.bin'
    ramb_path = base_name + '.ramb.bin'
    
    # Écrire les fichiers binaires avec header
    try:
        with open(rama_path, 'wb') as f:
            f.write(rama_data_with_header)
        print(f"Fichier RAMA créé: {rama_path}")
        
        with open(ramb_path, 'wb') as f:
            f.write(ramb_data_with_header)
        print(f"Fichier RAMB créé: {ramb_path}")
        
        print(f"Header: {bytes_per_line} octets/ligne, {num_lines} lignes")
        print(f"Taille données: {len(rama_data)} octets chacun ({len(pixels)} pixels)")
        print(f"Taille totale (avec header): {len(rama_data_with_header)} octets chacun")
    except Exception as e:
        print(f"Erreur lors de l'écriture des fichiers: {e}", file=sys.stderr)
        sys.exit(1)
    
    return rama_data_with_header, ramb_data_with_header


def main():
    parser = argparse.ArgumentParser(
        description='Encode une image PNG (indexée ou non, max 4 couleurs) en format BM4 (RAMA et RAMB)'
    )
    parser.add_argument('input', help='Chemin vers l\'image PNG d\'entrée')
    parser.add_argument('-o', '--output', help='Chemin de base pour les fichiers de sortie (optionnel). '
                                                'Les fichiers .rama.bin et .ramb.bin seront créés automatiquement')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.input):
        print(f"Erreur: Le fichier {args.input} n'existe pas", file=sys.stderr)
        sys.exit(1)
    
    encode_png_to_bm4(args.input, args.output)


if __name__ == '__main__':
    main()

