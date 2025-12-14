#!/usr/bin/env python3
"""
Module pour recommander un algorithme de compression basé sur les statistiques des runs.
"""

from typing import Dict, List, Tuple
from collections import Counter


def recommend_compression(run_counter: Counter, total_pixels: int, uncompressed_size_bytes: int = None) -> Dict:
    """
    Recommande un algorithme de compression basé sur la distribution des runs.
    
    Args:
        run_counter: Counter avec les longueurs de runs et leurs occurrences
        total_pixels: Nombre total de pixels dans l'image
    
    Returns:
        dict: Recommandations avec algorithme, ratio estimé, et détails
    """
    if not run_counter:
        return {
            'algorithm': 'none',
            'reason': 'Aucune statistique disponible'
        }
    
    total_runs = sum(run_counter.values())
    avg_run_length = total_pixels / total_runs if total_runs > 0 else 0
    
    # Calculer la distribution
    short_runs = sum(count for length, count in run_counter.items() if length <= 2)
    medium_runs = sum(count for length, count in run_counter.items() if 3 <= length <= 6)
    long_runs = sum(count for length, count in run_counter.items() if length >= 7)
    
    pct_short = (short_runs / total_runs * 100) if total_runs > 0 else 0
    pct_medium = (medium_runs / total_runs * 100) if total_runs > 0 else 0
    pct_long = (long_runs / total_runs * 100) if total_runs > 0 else 0
    
    # Analyser la distribution
    most_common_length = run_counter.most_common(1)[0][0] if run_counter else 0
    max_run_length = max(run_counter.keys())
    
    # Calculer la taille non compressée réelle
    # Pour BM4: 8 pixels = 1 octet (1 bit par pixel), donc 2 plans (RAMA + RAMB)
    if uncompressed_size_bytes is None:
        # Calculer à partir du nombre de pixels: ceil(pixels/8) par plan
        import math
        bytes_per_plan = math.ceil(total_pixels / 8)
        uncompressed_bm4_size = bytes_per_plan * 2  # 2 plans (RAMA + RAMB)
    else:
        # Utiliser la taille fournie (déjà pour les 2 plans ou un seul?)
        # On assume que c'est pour un seul plan, donc on multiplie par 2
        uncompressed_bm4_size = uncompressed_size_bytes * 2
    
    # Calculer le ratio de compression théorique pour RLE simple
    # Format RLE simple: [longueur][valeur] = 2 octets par run
    # Format RLE optimisé: codes variables selon la longueur
    rle_simple_size = total_runs * 2  # 2 octets par run (longueur + valeur)
    
    # Estimation pour RLE adaptatif avec codes variables
    # Runs courts (1-3): 1 octet (code 0-2 + valeur sur 2 bits)
    # Runs moyens (4-15): 2 octets (code + longueur 4 bits + valeur 2 bits)
    # Runs longs (16+): 3+ octets (code + longueur 16 bits + valeur 2 bits)
    rle_adaptive_size = 0
    for length, count in run_counter.items():
        if length <= 3:
            rle_adaptive_size += count * 1  # 1 octet pour runs très courts
        elif length <= 15:
            rle_adaptive_size += count * 2  # 2 octets pour runs moyens
        else:
            rle_adaptive_size += count * 3  # 3 octets pour runs longs (longueur sur 2 octets)
    
    # Pour BM4, on a 2 plans (RAMA et RAMB), donc on multiplie par 2
    rle_simple_bm4_size = rle_simple_size * 2
    rle_adaptive_bm4_size = rle_adaptive_size * 2
    
    # Recommandation basée sur l'analyse
    recommendations = []
    
    # Critère 1: Ratio pixels/runs
    if avg_run_length >= 4.0:
        recommendations.append({
            'algorithm': 'RLE_Adaptive',
            'confidence': 'high',
            'reason': f'Ratio pixels/runs élevé ({avg_run_length:.2f}), beaucoup de répétitions',
            'estimated_ratio': f'{rle_adaptive_bm4_size / uncompressed_bm4_size * 100:.1f}%',
            'estimated_size': rle_adaptive_bm4_size,
            'uncompressed_size': uncompressed_bm4_size
        })
    elif avg_run_length >= 2.5:
        recommendations.append({
            'algorithm': 'RLE_Adaptive',
            'confidence': 'medium',
            'reason': f'Ratio pixels/runs modéré ({avg_run_length:.2f}), compression RLE bénéfique',
            'estimated_ratio': f'{rle_adaptive_bm4_size / uncompressed_bm4_size * 100:.1f}%',
            'estimated_size': rle_adaptive_bm4_size,
            'uncompressed_size': uncompressed_bm4_size
        })
    else:
        recommendations.append({
            'algorithm': 'RLE_Simple',
            'confidence': 'low',
            'reason': f'Ratio pixels/runs faible ({avg_run_length:.2f}), peu de répétitions',
            'estimated_ratio': f'{rle_simple_bm4_size / uncompressed_bm4_size * 100:.1f}%',
            'estimated_size': rle_simple_bm4_size,
            'uncompressed_size': uncompressed_bm4_size
        })
    
    # Critère 2: Distribution des longueurs
    if pct_short > 50:
        recommendations.append({
            'algorithm': 'RLE_BitPacked',
            'confidence': 'medium',
            'reason': f'Beaucoup de runs courts ({pct_short:.1f}%), considérer encodage bitpacked',
            'note': 'Peut être combiné avec RLE pour les runs longs'
        })
    
    if max_run_length > 15:
        recommendations.append({
            'algorithm': 'RLE_VariableLength',
            'confidence': 'high',
            'reason': f'Runs longs présents (max: {max_run_length}), utiliser codes de longueur variables',
            'note': 'Recommandé pour optimiser les runs de toutes longueurs'
        })
    
    # Recommandation principale
    primary = recommendations[0] if recommendations else None
    
    return {
        'primary_recommendation': primary,
        'all_recommendations': recommendations,
        'statistics': {
            'total_runs': total_runs,
            'total_pixels': total_pixels,
            'avg_run_length': avg_run_length,
            'most_common_length': most_common_length,
            'max_run_length': max_run_length,
            'pct_short_runs': pct_short,
            'pct_medium_runs': pct_medium,
            'pct_long_runs': pct_long
        },
        'size_estimates': {
            'uncompressed': uncompressed_bm4_size,
            'rle_simple': rle_simple_bm4_size,
            'rle_adaptive': rle_adaptive_bm4_size,
            'rle_simple_ratio': f'{rle_simple_bm4_size / uncompressed_bm4_size * 100:.1f}%',
            'rle_adaptive_ratio': f'{rle_adaptive_bm4_size / uncompressed_bm4_size * 100:.1f}%'
        }
    }


def print_recommendation(recommendation: Dict) -> None:
    """
    Affiche les recommandations de compression de manière lisible.
    
    Args:
        recommendation: Dictionnaire de recommandation retourné par recommend_compression()
    """
    if not recommendation or 'primary_recommendation' not in recommendation:
        print("Aucune recommandation disponible")
        return
    
    print("\n" + "=" * 70)
    print("RECOMMANDATION DE COMPRESSION")
    print("=" * 70)
    
    primary = recommendation['primary_recommendation']
    stats = recommendation.get('statistics', {})
    size_est = recommendation.get('size_estimates', {})
    
    print(f"\nAlgorithme recommandé: {primary['algorithm']}")
    print(f"Confiance: {primary['confidence'].upper()}")
    print(f"Raison: {primary['reason']}")
    
    if 'estimated_ratio' in primary:
        print(f"Ratio de compression estimé: {primary['estimated_ratio']}")
        print(f"Taille estimée: {primary['estimated_size']} octets (vs {primary['uncompressed_size']} non compressé)")
    
    print("\nStatistiques clés:")
    print(f"  Longueur moyenne des runs: {stats.get('avg_run_length', 0):.2f} pixels")
    print(f"  Longueur la plus fréquente: {stats.get('most_common_length', 0)} pixels")
    print(f"  Longueur maximale: {stats.get('max_run_length', 0)} pixels")
    print(f"  Runs courts (≤2): {stats.get('pct_short_runs', 0):.1f}%")
    print(f"  Runs moyens (3-6): {stats.get('pct_medium_runs', 0):.1f}%")
    print(f"  Runs longs (≥7): {stats.get('pct_long_runs', 0):.1f}%")
    
    print("\nEstimations de taille (pour les 2 plans BM4):")
    print(f"  Non compressé: {size_est.get('uncompressed', 0)} octets")
    print(f"  RLE simple: {size_est.get('rle_simple', 0)} octets ({size_est.get('rle_simple_ratio', 'N/A')})")
    print(f"  RLE adaptatif: {size_est.get('rle_adaptive', 0)} octets ({size_est.get('rle_adaptive_ratio', 'N/A')})")
    
    all_recs = recommendation.get('all_recommendations', [])
    if len(all_recs) > 1:
        print("\nAutres recommandations:")
        for rec in all_recs[1:]:
            print(f"  - {rec['algorithm']}: {rec['reason']}")
            if 'note' in rec:
                print(f"    Note: {rec['note']}")
    
    print("=" * 70)

