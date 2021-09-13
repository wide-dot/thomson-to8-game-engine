package fr.bento8.to8.util;

public class FastMath {
	   static public void main(String[] args){
	         int range = 100;
	      float ep = (Pi * 2) / (Size_Ac * 6); // pass check
	      //float ep = (Pi * 2) / (Size_Ac * 4); // regular
	      //float ep = (Pi * 2) / (Size_Ac * 8); // theoretical but result dif on float error val calc
	      System.out.println("Accuracy Check: " + ep);
	      for(int x = -range; x <= range; x++){
	         for(int y = -range; y <= range; y++){
	            float a = (float)Math.atan2(x, y);
	            float b = atan2_Op_2(x, y);
	            float dif = a - b;
	            if(Math.abs(dif) > ep){
	               System.out.println("Dif x=" + x + " y= " + y);
	               System.out.println(a);
	               System.out.println(b);
	            }
	         }
	      }
	      System.out.println("Accuracy Check End");
	   }
	   
	   static final private int Size_Ac = 1000;
	   static final private int Size_Ar = Size_Ac + 1;
	   static final private float Pi = (float)Math.PI;
	   static final private float Pi_H = Pi / 2;
	   
	   static final private float Atan2[] = new float[Size_Ar];
	   static final private float Atan2_PM[] = new float[Size_Ar];
	   static final private float Atan2_MP[] = new float[Size_Ar];
	   static final private float Atan2_MM[] = new float[Size_Ar];
	   
	   static final private float Atan2_R[] = new float[Size_Ar];
	   static final private float Atan2_RPM[] = new float[Size_Ar];
	   static final private float Atan2_RMP[] = new float[Size_Ar];
	   static final private float Atan2_RMM[] = new float[Size_Ar];
	   static{
	      for(int i = 0; i <= Size_Ac; i++){
	         double d = (double)i / Size_Ac;
	         double x = 1;
	         double y = x * d;
	         float v = (float)Math.atan2(y, x);
	         Atan2[i] = v;
	         Atan2_PM[i] = Pi - v;
	         Atan2_MP[i] = -v;
	         Atan2_MM[i] = -Pi + v;
	         
	         Atan2_R[i] = Pi_H - v;
	         Atan2_RPM[i] = Pi_H + v;
	         Atan2_RMP[i] = -Pi_H + v;
	         Atan2_RMM[i] = -Pi_H - v;
	         // or
	         /*
	         Atan2[i] = (float)Math.atan2(y, x);
	         Atan2_PM[i] = (float)Math.atan2(y, -x);
	         Atan2_MP[i] = (float)Math.atan2(-y, x);
	         Atan2_MM[i] = (float)Math.atan2(-y, -x);
	         
	         Atan2_R[i] = (float)Math.atan2(x, y);
	         Atan2_RPM[i] = (float)Math.atan2(x, -y);
	         Atan2_RMP[i] = (float)Math.atan2(-x, y);
	         Atan2_RMM[i] = (float)Math.atan2(-x, -y);
	         */
	      }
	   }
	   
	   static final public float atan2_Op_2(double y, double x){
	      if(y < 0){
	         if(x < 0){
	            //(y < x) because == (-y > -x)
	            if(y < x) return Atan2_RMM[(int)(x / y * Size_Ac)];
	            else return Atan2_MM[(int)(y / x * Size_Ac)];   
	         }
	         else{
	            y = -y;
	            if(y > x) return Atan2_RMP[(int)(x / y * Size_Ac)];
	            else return Atan2_MP[(int)(y / x * Size_Ac)];
	         }
	      }
	      else{
	         if(x < 0){
	            x = -x;
	            if(y > x) return Atan2_RPM[(int)(x / y * Size_Ac)];
	            else return Atan2_PM[(int)(y / x * Size_Ac)];
	         }
	         else{
	            if(y > x) return Atan2_R[(int)(x / y * Size_Ac)];
	            else return Atan2[(int)(y / x * Size_Ac)];
	         }
	      }
	   }
	
}
