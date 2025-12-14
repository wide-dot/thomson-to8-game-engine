#!/usr/bin/env python3
"""
Module pour analyser les statistiques d'une image en vue de la compression.
Analyse les séquences de pixels de même couleur sur les lignes.
"""

from collections import Counter
from typing import List, Tuple


def analyze_line_runs(pixels: List[int], width: int, height: int) -> Counter:
    """
    Analyse les séquences de pixels de même couleur (runs) sur toutes les lignes.
    
    Args:
        pixels: Liste des indices de pixels (0-3) dans l'ordre ligne par ligne
        width: Largeur de l'image
        height: Hauteur de l'image
    
    Returns:
        Counter: Dictionnaire avec la longueur des runs comme clé et le nombre d'occurrences comme valeur
                 Exemple: {1: 150, 2: 45, 3: 12, ...} signifie 150 runs de 1 pixel, 45 runs de 2 pixels, etc.
    """
    if len(pixels) != width * height:
        raise ValueError(f"Le nombre de pixels ({len(pixels)}) ne correspond pas aux dimensions ({width}x{height})")
    
    run_lengths = []
    
    # Analyser chaque ligne
    for y in range(height):
        line_start = y * width
        line_pixels = pixels[line_start:line_start + width]
        
        # Compter les runs dans cette ligne
        if not line_pixels:
            continue
        
        current_color = line_pixels[0]
        current_run_length = 1
        
        for i in range(1, len(line_pixels)):
            if line_pixels[i] == current_color:
                current_run_length += 1
            else:
                # Fin d'un run, l'ajouter aux statistiques
                run_lengths.append(current_run_length)
                current_color = line_pixels[i]
                current_run_length = 1
        
        # Ajouter le dernier run de la ligne
        run_lengths.append(current_run_length)
    
    # Compter les occurrences de chaque longueur de run
    return Counter(run_lengths)


def print_run_statistics(run_counter: Counter, total_pixels: int) -> None:
    """
    Affiche les statistiques des runs de pixels.
    
    Args:
        run_counter: Counter avec les longueurs de runs et leurs occurrences
        total_pixels: Nombre total de pixels dans l'image
    """
    if not run_counter:
        print("Aucune statistique disponible")
        return
    
    print("\n=== Statistiques des séquences de pixels (runs) ===")
    print(f"Nombre total de runs: {sum(run_counter.values())}")
    print(f"Nombre total de pixels: {total_pixels}")
    print(f"Ratio pixels/runs: {total_pixels / sum(run_counter.values()):.2f}")
    print()
    
    # Trier par longueur de run
    sorted_runs = sorted(run_counter.items())
    
    print("Distribution des longueurs de runs:")
    print(f"{'Longueur':<10} {'Occurrences':<15} {'% des runs':<15} {'Pixels':<15} {'% des pixels':<15}")
    print("-" * 70)
    
    total_runs = sum(run_counter.values())
    
    for run_length, count in sorted_runs:
        pixels_in_runs = run_length * count
        pct_runs = (count / total_runs * 100) if total_runs > 0 else 0
        pct_pixels = (pixels_in_runs / total_pixels * 100) if total_pixels > 0 else 0
        
        print(f"{run_length:<10} {count:<15} {pct_runs:>6.2f}%{'':<8} {pixels_in_runs:<15} {pct_pixels:>6.2f}%")
    
    # Statistiques supplémentaires
    print()
    print("Statistiques supplémentaires:")
    print(f"  Run le plus court: {min(run_counter.keys())} pixel(s)")
    print(f"  Run le plus long: {max(run_counter.keys())} pixel(s)")
    print(f"  Longueur moyenne: {sum(k * v for k, v in run_counter.items()) / total_runs:.2f} pixels")
    
    # Top 10 des longueurs les plus fréquentes
    print()
    print("Top 10 des longueurs de runs les plus fréquentes:")
    top_runs = run_counter.most_common(10)
    for run_length, count in top_runs:
        print(f"  {run_length} pixel(s): {count} occurrences")


def get_statistics_summary(run_counter: Counter) -> dict:
    """
    Retourne un résumé des statistiques sous forme de dictionnaire.
    
    Args:
        run_counter: Counter avec les longueurs de runs et leurs occurrences
    
    Returns:
        dict: Dictionnaire avec les statistiques résumées
    """
    if not run_counter:
        return {}
    
    total_runs = sum(run_counter.values())
    total_pixels = sum(k * v for k, v in run_counter.items())
    
    return {
        'total_runs': total_runs,
        'total_pixels': total_pixels,
        'avg_run_length': total_pixels / total_runs if total_runs > 0 else 0,
        'min_run_length': min(run_counter.keys()),
        'max_run_length': max(run_counter.keys()),
        'most_common_length': run_counter.most_common(1)[0][0] if run_counter else 0,
        'distribution': dict(run_counter)
    }

