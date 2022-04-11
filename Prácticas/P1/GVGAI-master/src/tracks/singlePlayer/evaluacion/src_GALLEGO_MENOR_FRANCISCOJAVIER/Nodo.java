package tracks.singlePlayer.evaluacion.src_GALLEGO_MENOR_FRANCISCOJAVIER; 

import tools.Vector2d;
import core.game.StateObservation;
import java.util.ArrayList;
import java.util.PriorityQueue;

public class Nodo implements Comparable<Nodo>{

    public Vector2d posicion; 
    public double costeEstimado;
    public double costeTotal; 
    public Nodo padre;
    public double ID; 
    
    // Constructor
    public Nodo(Vector2d pos, StateObservation so)
    {
        posicion = pos; 
        costeEstimado = 0.0;
        costeTotal = 0.0;
        padre = null;
        // Considerar el mapa como una matriz con cada posicion siendo la 0,1,2,3,4 ...
        ID = pos.x + so.getObservationGrid().length*pos.y;
    }
    
    public Nodo(Vector2d pos, Nodo p, double parent_total_Cost, StateObservation so)
    {
    	costeEstimado = 0.0;
        costeTotal = parent_total_Cost+1.0;
        padre = p;
        posicion = pos; 
        ID = pos.x + so.getObservationGrid().length*pos.y;
        //numero de fila por 
    }
    
    public Nodo(Vector2d pos, Nodo p, double parent_total_Cost, double h, StateObservation so){
    	costeEstimado = h;
        costeTotal = parent_total_Cost+1.0;
        padre = p;
        posicion = pos;
        ID = pos.x + so.getObservationGrid().length*pos.y;
    }
    
    public Nodo(Vector2d pos, double h, StateObservation so){
    	costeEstimado = h;
        costeTotal = 0.0;
        padre = null;
        posicion = pos;
        ID = pos.x + so.getObservationGrid().length*pos.y;
    }

    @Override
    public int compareTo(Nodo n) {
        if(this.costeEstimado + this.costeTotal < n.costeEstimado + n.costeTotal) {
            return -1;
        }
        if(this.costeEstimado + this.costeTotal > n.costeEstimado + n.costeTotal) {
            return 1;
        }
        if(this.costeEstimado + this.costeTotal == n.costeEstimado + n.costeTotal) {
        	if(this.costeTotal < n.costeTotal) {
                return -1;
        	}
            if(this.costeTotal > n.costeTotal) {
                return 1;
            }
        }
        return 0;
    }

    @Override
    public boolean equals(Object o)
    {
        return this.posicion.equals(((Nodo)o).posicion);
    }
    
    // This function returns neighbour nodes
    public ArrayList<Nodo> neighbours(StateObservation so){
    	ArrayList<Nodo> neighbours = new ArrayList<Nodo>();
    	
    	// upper node
    	Vector2d pos = new Vector2d(this.posicion.x, this.posicion.y-1);
    	neighbours.add(new Nodo(pos, this, this.costeTotal, so));
    	
    	// bottom node
    	pos = new Vector2d(this.posicion.x, this.posicion.y+1);
    	neighbours.add(new Nodo(pos, this, this.costeTotal, so));
    	
    	// left node
    	pos = new Vector2d(this.posicion.x-1, this.posicion.y);
    	neighbours.add(new Nodo(pos, this, this.costeTotal, so));
    	
    	// right node
    	pos = new Vector2d(this.posicion.x+1, this.posicion.y);
    	neighbours.add(new Nodo(pos, this, this.costeTotal, so));
    	
    	return neighbours; 
    }
    
    public double distManhattan_(Vector2d v, Vector2d w){
    	return Math.abs(v.x-w.x) + Math.abs(v.y-w.y);
    }
    
    public PriorityQueue<Nodo> neighboursIDAStar(Nodo objective, StateObservation so){
    	PriorityQueue<Nodo> neighbours = new PriorityQueue<Nodo>();
    	
    	// upper node
    	Vector2d pos = new Vector2d(this.posicion.x, this.posicion.y-1);
    	neighbours.add(new Nodo(pos,this,this.costeTotal, distManhattan_(objective.posicion, pos), so));
    	
    	// bottom node
    	pos = new Vector2d(this.posicion.x, this.posicion.y+1);
    	neighbours.add(new Nodo(pos,this,this.costeTotal, distManhattan_(objective.posicion, pos), so));
    	
    	// left node
    	pos = new Vector2d(this.posicion.x-1, this.posicion.y);
    	neighbours.add(new Nodo(pos,this,this.costeTotal, distManhattan_(objective.posicion, pos), so));
    	
    	// right node
    	pos = new Vector2d(this.posicion.x+1, this.posicion.y);
    	neighbours.add(new Nodo(pos,this,this.costeTotal, distManhattan_(objective.posicion, pos), so));
    	    	    	
    	return neighbours; 
    }
    
    public ArrayList<Nodo> neighboursAStar(Nodo objective, StateObservation so){
    	ArrayList<Nodo> neighbours = new ArrayList<Nodo>();
    	
    	// upper node
    	Vector2d pos = new Vector2d(this.posicion.x, this.posicion.y-1);
    	neighbours.add(new Nodo(pos,this,this.costeTotal, distManhattan_(objective.posicion, pos), so));
    	
    	// bottom node
    	pos = new Vector2d(this.posicion.x, this.posicion.y+1);
    	neighbours.add(new Nodo(pos,this,this.costeTotal, distManhattan_(objective.posicion, pos), so));
    	
    	// left node
    	pos = new Vector2d(this.posicion.x-1, this.posicion.y);
    	neighbours.add(new Nodo(pos,this,this.costeTotal, distManhattan_(objective.posicion, pos), so));
    	
    	// right node
    	pos = new Vector2d(this.posicion.x+1, this.posicion.y);
    	neighbours.add(new Nodo(pos,this,this.costeTotal, distManhattan_(objective.posicion, pos), so));
    	    	    	
    	return neighbours; 
    }
    
}