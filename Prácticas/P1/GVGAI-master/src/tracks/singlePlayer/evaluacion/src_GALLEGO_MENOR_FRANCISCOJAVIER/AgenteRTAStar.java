package tracks.singlePlayer.evaluacion.src_GALLEGO_MENOR_FRANCISCOJAVIER; 

import java.util.ArrayList;
import java.util.Collections;
import java.util.Deque;
import java.util.Hashtable;
import java.util.LinkedHashSet;
import java.util.PriorityQueue;
import java.util.ArrayDeque;
import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import ontology.Types.ACTIONS;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

public class AgenteRTAStar extends AbstractPlayer {
	Deque<Types.ACTIONS> path = new ArrayDeque<>();
	static boolean pathIsCalculated = false;
	Vector2d fescala;
	Nodo inicial, objetivo;
	int nodosExpandidos = 0, contador = 0;
	// Key: Node ID. Value: Heuristic value
	Hashtable<Double,Double> visitados = new Hashtable<Double,Double>();				

    /**
     * Public constructor with state observation and time due.
     * @param so state observation of the current game.
     * @param elapsedTimer Timer for the controller creation.
     */
    public AgenteRTAStar(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
    {
    	fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length ,
                stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);
    	inicial = new Nodo(new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y), stateObs);
    	objetivo = new Nodo(new Vector2d(stateObs.getPortalsPositions()[0].get(0).position.x/fescala.x, stateObs.getPortalsPositions()[0].get(0).position.y / fescala.y), stateObs);    	
    }
    
    //Distancia de Manhattan (base de nuestra heurística)
    public double distManhattan(Nodo origen, Nodo destino){
    	return Math.abs(origen.posicion.x-destino.posicion.x) + Math.abs(origen.posicion.y-destino.posicion.y);
    }
    
    public LinkedHashSet<Double> getObstacles(StateObservation stateObs) {
		LinkedHashSet<Double> obstaculos = new LinkedHashSet<>();
		ArrayList<Observation>[] immovablePositions = stateObs.getImmovablePositions();
		
		// Añadimos los IDs correspondientes a los obstaculos
	    for(Observation obs : immovablePositions[0])
	    	obstaculos.add( Math.floor(obs.position.x / fescala.x) + stateObs.getObservationGrid().length * Math.floor(obs.position.y / fescala.y));
	    
	    for(Observation obs : immovablePositions[1])
	    	obstaculos.add( Math.floor(obs.position.x / fescala.x) + stateObs.getObservationGrid().length * Math.floor(obs.position.y / fescala.y));
	    	    
	    return obstaculos;
	}
    
    public boolean isValid(StateObservation stateObs, Nodo node) {
    	if(	node.posicion.x < stateObs.getObservationGrid().length 
    		&& node.posicion.y < stateObs.getObservationGrid()[0].length ){
    			return true;
    		}
    	return false;
    }     
    
	public Types.ACTIONS findPath(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {		
		Nodo actual, siguiente_nodo = null; 
		ArrayList<Nodo> neighbours; 								        
		LinkedHashSet<Double> obstaculos = getObstacles(stateObs);	
		double f, h_actual, best = Double.MAX_VALUE, second_best = Double.MAX_VALUE;		 				
		
		actual = new Nodo(new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y), stateObs);		
		
		neighbours = actual.neighboursAStar(objetivo, stateObs);
		/*
		 * Como RTA* es un algoritmo de busqueda heurística (en tiempo real), el orden de exploración
		 * estará ordenado por f(n). En caso de empate por g(n). Por último, por el orden por defecto.
		 */
		Collections.sort(neighbours);

		// Buscamos el nodo vecino al que movernos en el siguiente movimiento
		for(Nodo vecino : neighbours)
			if(isValid(stateObs, vecino) && !obstaculos.contains(vecino.ID)) {
				
				// Si ya hemos visitado el nodo, obtenemos su valor heuristico del hash
				if(visitados.containsKey(vecino.ID))
					f = visitados.get(vecino.ID);
				else
					// Todos los costes son 1. Solo importa valor heurístico
					f = vecino.costeEstimado;
				
				if(f < best) {
					second_best = best;
					best = f; 
					siguiente_nodo = vecino;
				}
				
				else {
					if(f < second_best)
						second_best = f;
				}
			}
						
		// Conseguimos el valor de h(x)
		if(visitados.containsKey(actual.ID)) 
			h_actual = visitados.get(actual.ID);		
		else
			h_actual = actual.costeEstimado;
				
		// Buscamos el máximo. Primer caso: existe el 2º minimo
		if(second_best != Double.MAX_VALUE) {
			if(second_best+1 > h_actual)
				h_actual = second_best+1;
		}
		// No existe 2º minimo
		else {
			if(best+1 > h_actual)
				h_actual = best+1;
		}
		
		// Actualizamos el valor heuristico en el hash
		visitados.remove(actual.ID);		
		visitados.put(actual.ID, h_actual);

		contador++;
		if(siguiente_nodo.equals(objetivo)) {
			System.out.println("Consumo de Memoria RTA: " + visitados.size());
			System.out.println("Nodos Expandidos RTA: " + contador);
		}							
		
		// Accion correspondiente a realizar
		if (actual.posicion.y > siguiente_nodo.posicion.y) {
			return Types.ACTIONS.ACTION_UP;	
		}
		else if (actual.posicion.y < siguiente_nodo.posicion.y) {
			return Types.ACTIONS.ACTION_DOWN;	
		}
		else if (actual.posicion.x > siguiente_nodo.posicion.x) {
			return Types.ACTIONS.ACTION_LEFT;	
		}
		else if (actual.posicion.x < siguiente_nodo.posicion.x) {
			return Types.ACTIONS.ACTION_RIGHT;	
		}
		
		return ACTIONS.ACTION_NIL;		
	}

    /**
     * Picks an action. This function is called every game step to request an
     * action from the player.
     * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
     * @return An action for the current state
     */
    public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
    	
    	Types.ACTIONS accion;
		accion = findPath(stateObs, elapsedTimer);
		return accion;  		    	        
    }

}