package fr.bento8.to8.build;

public class ObjectCode {

	public String name;
	public ObjectBin code;
	
	public ObjectCode(Object obj) throws Exception {
		this.name = new String(obj.name);
		this.code = new ObjectBin(obj);
	}	
}
