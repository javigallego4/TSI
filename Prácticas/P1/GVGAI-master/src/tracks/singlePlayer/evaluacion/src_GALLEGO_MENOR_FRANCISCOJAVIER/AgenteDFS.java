package tracks.singlePlayer.evaluacion.src_GALLEGO_MENOR_FRANCISCOJAVIER; 

// Import EDs
import java.util.ArrayList;

import java.util.Queue;
import java.util.Deque;
import java.util.Hashtable;
import java.util.LinkedHashSet;
import java.util.ArrayDeque;
import tools.Vector2d;
import tools.ElapsedCpuTimer;

// Import GVGAI utils
import core.game.Observation;
import core.player.AbstractPlayer;
import ontology.Types;
import core.game.StateObservation;


public class AgenteDFS extends AbstractPlayer {	
	Deque<Types.ACTIONS> path = new ArrayDeque<>();
	static boolean pathIsCalculated;
	Vector2d fescala;
	Nodo initial, objective;
	Hashtable<Double,Boolean> visitados = new Hashtable<Double,Boolean>();
	int nodosExpandidos = 0;
	LinkedHashSet<Double> obstaculos = new LinkedHashSet<>();
	int contador = 0;

	
	/**
     * Public constructor with state observation and time due.
     * @param so state observation of the current game.
     * @param elapsedTimer Timer for the controller creation.
     */
    public AgenteDFS(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
    {
    	fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length ,
                stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);
		initial = new Nodo(new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y), stateObs);
		objective = new Nodo(new Vector2d(stateObs.getPortalsPositions()[0].get(0).position.x/fescala.x, stateObs.getPortalsPositions()[0].get(0).position.y / fescala.y), stateObs);
		obstaculos = getObstacles(stateObs);
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
    
    public boolean isValid(StateObservation stateObs, Nodo nodo) {
    	boolean valido;
    	
    	if(	nodo.posicion.x < stateObs.getObservationGrid().length && nodo.posicion.y < stateObs.getObservationGrid()[0].length ){
    		valido = true;
    	}
    	else {
    		valido = false;
    	}
    	return valido;
    }
	
	/*
	 * El proceso es: mediante FindPath vamos añadiendo quien es el padre de cada nodo
	 * Entonces para encontrar el camino comenzaremos por el nodo objetivo e iremos
	 * subiendo niveles en el "arbol" mediante el atributo de padre que tiene la estructura de un nodo
	 * Vamos añadiendo las acciones correspondientes en primer lugar, entonces como emepzamos por el nodo objetivo
	 * y vamos "de atras hacia delante" el orden de acciones a realizar es correcto. 
	 */
	void printPath() {
    	Nodo current = objective;
    	
    	while (current != initial) {
    		
    		Nodo parent = current.padre;
    		
    		if (current.posicion.x > parent.posicion.x) {
    			path.addFirst(Types.ACTIONS.ACTION_RIGHT);
    		} else if (current.posicion.x < parent.posicion.x) {
    			path.addFirst(Types.ACTIONS.ACTION_LEFT);	
    		} else if (current.posicion.y < parent.posicion.y) {
    			path.addFirst(Types.ACTIONS.ACTION_UP);
    		} else if(current.posicion.y > parent.posicion.y){
    			path.addFirst(Types.ACTIONS.ACTION_DOWN);
    		}
    		
    		current = parent;
    	}    	
    }
	
	/*
	 * Seguimos el pseudocodigo de las transparencias
	 */
	public void findPath(StateObservation stateObs, Nodo inicial, Nodo objetivo) {		
		long tInicio = System.nanoTime();
		boolean encontrado;
		visitados.put(inicial.ID, true);
		encontrado = DFS_busqueda(stateObs, inicial, objetivo);
				
		if(encontrado) {
			System.out.println("Cargando el plan...");
			System.out.println("Nodos expandidos DFS: " + nodosExpandidos);
			System.out.println("Consumo de Memoria DFS: " + visitados.size());
			printPath();
			long tFinal = System.nanoTime();
			long tiempoTotalEnSegundos = (tFinal - tInicio)/1000000;
			System.out.println("Tiempo Ejecución BFS: " + tiempoTotalEnSegundos);
		}
	}
	
	public boolean DFS_busqueda(StateObservation stateObs, Nodo u, Nodo objetivo) {		
		nodosExpandidos += 1;
		if(u.equals(objetivo)) {
			objetivo.padre = u.padre;
			return true; 
		}
		
		ArrayList<Nodo> neighbours = u.neighbours(stateObs);					
		for(Nodo vecino: neighbours) {
			if(isValid(stateObs, vecino) && !visitados.containsKey(vecino.ID) && !obstaculos.contains(vecino.ID)) {
				visitados.put(vecino.ID, true);	
				if(DFS_busqueda(stateObs, vecino, objetivo)) {
					return true;
				}
			}
		}
		
		return false; 
	}
	
	public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
    	/* Si aún no hemos calculado la ruta, la calculamos. 
    	 * En el caso de que si, retornamos la siguiente accion
    	 */
		if (!pathIsCalculated) {
    		findPath(stateObs, initial, objective);
    		pathIsCalculated = true;
    	}
    	return path.poll();
        
    }
	
}