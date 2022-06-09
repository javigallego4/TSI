package tracks.singlePlayer.evaluacion.src_GALLEGO_MENOR_FRANCISCOJAVIER; 

import tools.Vector2d;
import core.game.StateObservation;
import java.util.ArrayList;
import java.util.PriorityQueue;

public class Nodo implements Comparable<Nodo>{

    public Vector2d posicion; 
    public double heuristicValue;
    public double currentCost; 
    public Nodo parent;
    public double ID; 
    
    // Constructor
    public Nodo(Vector2d pos, StateObservation so)
    {
        posicion = pos; 
        heuristicValue = 0.0;
        currentCost = 0.0;
        parent = null;
        // Considerar el mapa como una matriz con cada posicion siendo la 0,1,2,3,4 ...
        ID = pos.x + so.getObservationGrid().length*pos.y;
    }
    
    public Nodo(Vector2d pos, Nodo p, double parent_total_Cost, StateObservation so)
    {
    	heuristicValue = 0.0;
        currentCost = parent_total_Cost+1.0;
        parent = p;
        posicion = pos; 
        ID = pos.x + so.getObservationGrid().length*pos.y;
        //numero de fila por 
    }
    
    public Nodo(Vector2d pos, Nodo p, double parent_total_Cost, double h, StateObservation so){
    	heuristicValue = h;
        currentCost = parent_total_Cost+1.0;
        parent = p;
        posicion = pos;
        ID = pos.x + so.getObservationGrid().length*pos.y;
    }
    
    public Nodo(Vector2d pos, double h, StateObservation so){
    	heuristicValue = h;
        currentCost = 0.0;
        parent = null;
        posicion = pos;
        ID = pos.x + so.getObservationGrid().length*pos.y;
    }

    @Override
    public int compareTo(Nodo n) {
        if(this.heuristicValue + this.currentCost < n.heuristicValue + n.currentCost) {
            return -1;
        }
        if(this.heuristicValue + this.currentCost > n.heuristicValue + n.currentCost) {
            return 1;
        }
        if(this.heuristicValue + this.currentCost == n.heuristicValue + n.currentCost) {
        	if(this.currentCost < n.currentCost) {
                return -1;
        	}
            if(this.currentCost > n.currentCost) {
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
    	neighbours.add(new Nodo(pos, this, this.currentCost, so));
    	
    	// bottom node
    	pos = new Vector2d(this.posicion.x, this.posicion.y+1);
    	neighbours.add(new Nodo(pos, this, this.currentCost, so));
    	
    	// left node
    	pos = new Vector2d(this.posicion.x-1, this.posicion.y);
    	neighbours.add(new Nodo(pos, this, this.currentCost, so));
    	
    	// right node
    	pos = new Vector2d(this.posicion.x+1, this.posicion.y);
    	neighbours.add(new Nodo(pos, this, this.currentCost, so));
    	
    	return neighbours; 
    }
    
    public double distManhattan_(Vector2d v, Vector2d w){
    	return Math.abs(v.x-w.x) + Math.abs(v.y-w.y);
    }
    
    public PriorityQueue<Nodo> neighboursIDAStar(Nodo objective, StateObservation so){
    	PriorityQueue<Nodo> neighbours = new PriorityQueue<Nodo>();
    	
    	// upper node
    	Vector2d pos = new Vector2d(this.posicion.x, this.posicion.y-1);
    	neighbours.add(new Nodo(pos,this,this.currentCost, distManhattan_(objective.posicion, pos), so));
    	
    	// bottom node
    	pos = new Vector2d(this.posicion.x, this.posicion.y+1);
    	neighbours.add(new Nodo(pos,this,this.currentCost, distManhattan_(objective.posicion, pos), so));
    	
    	// left node
    	pos = new Vector2d(this.posicion.x-1, this.posicion.y);
    	neighbours.add(new Nodo(pos,this,this.currentCost, distManhattan_(objective.posicion, pos), so));
    	
    	// right node
    	pos = new Vector2d(this.posicion.x+1, this.posicion.y);
    	neighbours.add(new Nodo(pos,this,this.currentCost, distManhattan_(objective.posicion, pos), so));
    	    	    	
    	return neighbours; 
    }
    
    public ArrayList<Nodo> neighboursAStar(Nodo objective, StateObservation so){
    	ArrayList<Nodo> neighbours = new ArrayList<Nodo>();
    	
    	// upper node
    	Vector2d pos = new Vector2d(this.posicion.x, this.posicion.y-1);
    	neighbours.add(new Nodo(pos,this,this.currentCost, distManhattan_(objective.posicion, pos), so));
    	
    	// bottom node
    	pos = new Vector2d(this.posicion.x, this.posicion.y+1);
    	neighbours.add(new Nodo(pos,this,this.currentCost, distManhattan_(objective.posicion, pos), so));
    	
    	// left node
    	pos = new Vector2d(this.posicion.x-1, this.posicion.y);
    	neighbours.add(new Nodo(pos,this,this.currentCost, distManhattan_(objective.posicion, pos), so));
    	
    	// right node
    	pos = new Vector2d(this.posicion.x+1, this.posicion.y);
    	neighbours.add(new Nodo(pos,this,this.currentCost, distManhattan_(objective.posicion, pos), so));
    	    	    	
    	return neighbours; 
    }
    
}