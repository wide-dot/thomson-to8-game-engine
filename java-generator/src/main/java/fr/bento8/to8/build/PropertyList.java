package fr.bento8.to8.build;

import java.util.HashMap;
import java.util.Properties;
import java.util.Map.Entry;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class PropertyList {

	/**
	 * Effectue le chargement d'une liste de propriétés de type propriete=key1;xxx, propriete=key2;xxx, ...
	 * 
	 * @param Properties propriétés, String nom de la propriété
	 * @return HashMap<String, String[]> La liste des valeurs pour la propriété
	 */
	public static HashMap<String, String[]> get(Properties properties, String name) 
	{
		HashMap<String, String[]> result = new HashMap<String, String[]>();
		Pattern pn = Pattern.compile("^" + name + "\\.(.*)$") ;  
		Matcher m = null;
		for (Entry<java.lang.Object, java.lang.Object> entry : properties.entrySet())
		{
			m = pn.matcher(((String)entry.getKey())) ;  
			if (m.find()) {
				result.put(m.group(1), ((String)entry.getValue()).split(";"));
			}
		}

		return result;
	}
	
}