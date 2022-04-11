package tracks.singlePlayer.evaluacion.src_GALLEGO_MENOR_FRANCISCOJAVIER; 

//import java.util.ArrayList;
import java.util.Deque;
import java.util.ArrayDeque;
import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;
import java.util.Hashtable;
import java.util.LinkedHashSet;
import java.util.PriorityQueue;
import java.util.ArrayList;
import java.util.Collections;

public class AgenteIDAStar extends AbstractPlayer {
	Deque<Types.ACTIONS> path = new ArrayDeque<>();
	static boolean pathIsCalculated = false;
	Vector2d fescala;
	Nodo initial, objective;
	Hashtable<Double, Boolean> elements_in_ruta = new Hashtable<Double, Boolean>();
	double contador_nodos_expandidos = 0;
    /**
     * Public constructor with state observation and time due.
     * @param so state observation of the current game.
     * @param elapsedTimer Timer for the controller creation.
     */
    public AgenteIDAStar(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
    {
    	fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length ,
                stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);
		initial = new Nodo(new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y), stateObs);
		objective = new Nodo(new Vector2d(stateObs.getPortalsPositions()[0].get(0).position.x/fescala.x, stateObs.getPortalsPositions()[0].get(0).position.y / fescala.y), stateObs);
		initial.costeEstimado = distManhattan(initial,objective);
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
    
    void printPath() {
    	Nodo current = objective;    	        	
    	
    	while (current != initial) {
    		Nodo parent = current.padre;
    		
    		if (current.posicion.x > parent.posicion.x) 
    			path.addFirst(Types.ACTIONS.ACTION_RIGHT);
    		
    		 else if (current.posicion.x < parent.posicion.x) 
    			path.addFirst(Types.ACTIONS.ACTION_LEFT);
    		
    		 else if (current.posicion.y < parent.posicion.y) 
    			path.addFirst(Types.ACTIONS.ACTION_UP);
    		
    		 else if(current.posicion.y > parent.posicion.y)
    			path.addFirst(Types.ACTIONS.ACTION_DOWN);
    		    		
    		current = parent;
    	}
    }    

    public void findPath(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
		long tInicio = System.nanoTime();
    	Deque<Nodo> ruta = new ArrayDeque<Nodo>();
    	double cota, t;
    	//boolean found = false;
    	
    	cota = initial.costeEstimado;    	
    	ruta.add(initial);
		elements_in_ruta.put(initial.ID, true);
    	
    	while(true) {
    		t = search(ruta, 0, cota, stateObs);
    		
    		if(t == 0) {	// El 0 va a ser nuestro ENCONTRADO del pseudocodigo
    			//found = true;
    			break; 
    		}
    		
    		if(t == Double.MAX_VALUE) {
    			ruta.clear();
    			break;    		
    		}
    		
    		cota = t;    		    		
    	}
    			
		System.out.println("Cargando el plan...");
		System.out.println("Consumo de Memoria IDA: " + ruta.size());
		System.out.println("Nodos Expandidos IDA: " + contador_nodos_expandidos);
		printPath();
		long tFinal = System.nanoTime();
		long tiempoTotalEnSegundos = (tFinal - tInicio)/1000000;
		System.out.println("Tiempo Ejecución BFS: " + tiempoTotalEnSegundos);     	
    		
    }
    
    public double search(Deque<Nodo> ruta, double g, double cota, StateObservation stateObs) {
    	Nodo nodo; 
    	double minimo = Double.MAX_VALUE;
    	double f, t = Double.MAX_VALUE;
		LinkedHashSet<Double> obstaculos = getObstacles(stateObs);
    	
		/*
		 * Imaginar el problema de las transparencias. Para el nodo inicial A, f no es mayor que cota
		 * Añadimos todos sus vecinos a ruta. Estos son B y C. Para cada uno de ellos exploramos sus ramas
		 * Como el metodo neighbours nos ordena el array de vecinos segun la heuristica, empezamos por C
		 * Dentro del search correspondiente, la f del C seria f = 6 + 5 = 11. Como es menor que el minimo (inicializado a infinito) minimo = 11.
		 * Pasamos a B. Su f = 12. Como no es menor que minimo. Finalizamos el metodo devolviendo 11. 
		 * 
		 * En findPath como 11 != -1 (valor escogido para representar que hemos llegado al objetivo) actualizamos la cota, y procedemos con el search again
		 * En esta ocasion exploraremos un nivel mas de profundidad EN LA RAMA DE C NADA MAS 
		 *  
		 */						
		
		nodo = ruta.peekLast();
		f = g + nodo.costeEstimado;
		
    	if(f>cota)
    		return f; 
    	
		contador_nodos_expandidos++;
    	if(nodo.equals(objective)) {
    		objective.padre = nodo.padre;
    		return 0;	// limite
    	}
    	
    	PriorityQueue<Nodo> neighbours = new PriorityQueue<Nodo>();
    	neighbours = nodo.neighboursIDAStar(objective, stateObs);
    	
    	for(Nodo vecino :neighbours) {
    		if(isValid(stateObs, vecino) && !obstaculos.contains(vecino.ID)) { 
    			if(!elements_in_ruta.containsKey(vecino.ID)) {
    				ruta.add(vecino);
    				elements_in_ruta.put(vecino.ID, true);
    				
    				t = search(ruta, g+1, cota, stateObs);
    				
    				if(t == 0) { 	// limite. Si hemos llegado al nodo objetivo.
    					return 0;
    				}
    				    					
    				if(t < minimo) { 
    					minimo = t; 
    				}
    				
    				elements_in_ruta.remove(ruta.pollLast().ID);    				
    			}
    		}
    	}
    	
    	return minimo;     	
    }

    /**
     * Picks an action. This function is called every game step to request an
     * action from the player.
     * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
     * @return An action for the current state
     */
    public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
    	if (!pathIsCalculated) {
    		findPath(stateObs, elapsedTimer);
    		pathIsCalculated = true;
        	//System.out.println(path.size());
    	}
		
    	return path.poll();		
        
    }

}