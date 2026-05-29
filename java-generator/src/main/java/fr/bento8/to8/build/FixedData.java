package fr.bento8.to8.build;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

/**
 * Binaire pré-assemblé chargé à une page+offset RAM imposés (pas de knapsack).
 *
 * Déclaration dans le .properties d'un game-mode :
 *   data.&lt;NomLogique&gt;=&lt;chemin_bin&gt;;&lt;page&gt;;&lt;offset_within_page&gt;
 *
 * Exemple :
 *   data.RoadPatternsDark=./tools/output/road_lines_ram/road_patterns_dark.bin;3;$0000
 *   data.PerspRecipA=./engine/projection/Persp_Recip_paged.bin;3;$1000
 *
 * Le builder :
 *   - charge le .bin
 *   - écrit son contenu dans la RamImage du game-mode à la position imposée
 *     via {@code RamImage.setData(page, offset, bytes)}
 *   - crée des entrées RAMLoaderIndex avec {@code split=true} afin que
 *     la logique d'inversion demi-pages (BuildDisk:~2219) s'applique au runtime
 *   - émet 2 constantes dans le .glb du game-mode :
 *       {@code &lt;NomLogique&gt;_PAGE}   = numéro de page
 *       {@code &lt;NomLogique&gt;_OFFSET} = offset cart-view dans la page
 *
 * Contraintes :
 *   - {@code page} ∈ [3, nbMaxPagesRAM-1]
 *     (interdit : 0=loader RAMA, 1=game-mode résident, 2=loader work buffer)
 *   - {@code offset + bin_size} ≤ {@code RamImage.PAGE_SIZE} (= $4000)
 *
 * @author Benoît Rousseau
 */
public class FixedData {

    /** Nom logique exposé dans le .glb (e.g. "RoadPatternsDark"). */
    public final String name;

    /** Chemin vers le fichier binaire pré-assemblé. */
    public final String filePath;

    /** Page RAM cible (3..nbMaxPagesRAM-1). */
    public final int page;

    /** Offset dans la page (cart-view, 0..$3FFF). */
    public final int offset;

    /** Contenu du binaire chargé depuis disque. */
    public final byte[] bytes;

    public FixedData(String name, String filePath, int page, int offset) throws Exception {
        this.name = name;
        this.filePath = filePath;
        this.page = page;
        this.offset = offset;

        // Validation page : SEULE la page 3 est autorisée.
        // FixedData est conçu pour le pattern "load to page 3, copy to page 0
        // demi-pages au boot" (cf. CopyPageToDemiPage0.asm). Pour les autres
        // usages d'allocation paginée, passer par le mécanisme objet standard
        // (= object.X=... + knapsack pages 4+).
        if (page != 3) {
            throw new Exception("FixedData '" + name + "' : page " + page
                + " interdite. SEULE la page 3 est autorisée pour le mécanisme"
                + " FixedData (= page intermédiaire avant copie vers page 0"
                + " demi-pages). Pour une autre allocation, utiliser le"
                + " mécanisme object.X=... (knapsack pages 4+).");
        }

        // Lecture du .bin
        try {
            this.bytes = Files.readAllBytes(Paths.get(filePath));
        } catch (IOException e) {
            throw new Exception("FixedData '" + name + "' : impossible de lire "
                + filePath, e);
        }

        // Validation offset+size
        int endOffset = offset + bytes.length;
        if (endOffset > 0x4000) {
            throw new Exception("FixedData '" + name + "' : offset $"
                + Integer.toHexString(offset).toUpperCase() + " + taille "
                + bytes.length + " octets déborde la page (> $4000)");
        }
    }

    @Override
    public String toString() {
        return String.format("FixedData[%s, file=%s, page=%d, offset=$%04X, size=%d]",
            name, filePath, page, offset, bytes.length);
    }
}
