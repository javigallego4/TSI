package tracks.singlePlayer.evaluacion.src_GALLEGO_MENOR_FRANCISCOJAVIER; 

import java.util.ArrayList;
import java.util.Collections;
import java.util.Deque;
import java.util.LinkedHashSet;
import java.util.PriorityQueue;
import java.util.ArrayDeque;
import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

public class AgenteAStar extends AbstractPlayer {
	Deque<Types.ACTIONS> path = new ArrayDeque<>();
	static boolean pathIsCalculated = false;
	Vector2d fescala;
	Nodo inicial, objetivo;
	int nodosExpandidos = 0;

    /**
     * Public constructor with state observation and time due.
     * @param so state observation of the current game.
     * @param elapsedTimer Timer for the controller creation.
     */
    public AgenteAStar(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
    {
    	fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length ,
                stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);
    	inicial = new Nodo(new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y), stateObs);
    	objetivo = new Nodo(new Vector2d(stateObs.getPortalsPositions()[0].get(0).position.x/fescala.x, stateObs.getPortalsPositions()[0].get(0).position.y / fescala.y), stateObs);

    	// Nunca usamos el padre de inicial. Esto lo hacemos para que no de error en la 109 al hacer el equals.
    	// CAMBIAMOS EN EL PRINTPATH EL while(current.parent == null), el null por inicial
		inicial.padre = objetivo;
    }
    
    void printPath() {
    	Nodo current = objetivo;    	    
    	
    	while (current != inicial) {

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
    
	public void findPath(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {		
		long tInicio = System.nanoTime();
		ArrayList<Nodo> abiertos = new ArrayList<Nodo>();
		ArrayList<Nodo> cerrados = new ArrayList<Nodo>();
		int longitud_maxima = 0;
				
		Nodo actual; 
		ArrayList<Nodo> neighbours; 								        
		LinkedHashSet<Double> obstaculos = getObstacles(stateObs);
		int index;
				
		inicial.costeEstimado = distManhattan(inicial, objetivo);
		abiertos.add(inicial);
		
		while (true) {
			if(abiertos.size() + cerrados.size() > longitud_maxima) {
				longitud_maxima = abiertos.size() + cerrados.size();
			}
			// Ordenamos abiertos según f(n)			
			Collections.sort(abiertos);
			// Primer elemento de abiertos es el mejor candidato
			actual = abiertos.get(0);
			nodosExpandidos += 1;
						
			// Comprobamos si estamos en el nodo objetivo
			if(actual.equals(objetivo)) {
				objetivo.padre = actual.padre;
				break;
			}
			
			/* Puesto que estamos visitando 'actual', lo eliminamos de abiertos
			y lo añadimos a cerrados*/
			abiertos.remove(actual);
			cerrados.add(actual);
			
			// Obtenemos vecinos del nodo 'actual'
			neighbours = actual.neighboursAStar(objetivo, stateObs);

			for(Nodo vecino : neighbours) {
				// Si el nodo vecino es válido y no es un obstáculo
				if(isValid(stateObs, vecino)  && !obstaculos.contains(vecino.ID)) {
					// Si ya hemos visitado el nodo padre -> Pass
					if(!vecino.equals(actual.padre)) {
						/*
						 * Si ya hemos visitado este nodo, pero el padre no (equivalente a no haber explorado esta ruta que es distinta)
						 * Comparamos los costes obtenidos en cada camino realizado, y nos quedamos con el mejor
						 */						
						if (cerrados.contains(vecino)){							
							index = cerrados.indexOf(vecino);							
							/*
							 *  Si el coste actual del vecino es menor que el valor previo, entonces la ruta actual hasta el nodo
							 *  vecino es mejor que la anterior. Por tanto, actualizamos valores.
							*/
							if(cerrados.get(index).costeTotal > vecino.costeTotal) {
								cerrados.remove(index);
								/*
								 *  Como el vecino está en cerrados (nodos ya visitados), no está en abiertos.
								 *  Lo eliminamos de cerrados, y añadimos en la lista de abiertos para actualizar su g(n)
								*/
								abiertos.add(vecino);
							}
						}
						
						/*
						 *  Si es la 1ª vez que nos encontramos con el nodo, pues no está ni en la lista de nodos pendientes
						 *  de visitar, lo añadimos a esta.
						*/
						else if(!cerrados.contains(vecino) && !abiertos.contains(vecino)) {
								abiertos.add(vecino);
						}
						
						/*
						 * Si el nodo sucesor se encuentra pendiente de visitar y obtenemos una mejor ruta para llegar hasta él,
						 * actualizamos valores.
						 */
						else if(abiertos.contains(vecino)) {
							index = abiertos.indexOf(vecino);
	
							if(abiertos.get(index).costeTotal > vecino.costeTotal) {
								abiertos.get(index).costeTotal = vecino.costeTotal;
							}							
						}											
					}
				}
			}			
		}				
		
		System.out.println("Nodos expandidos A*: " + nodosExpandidos);
		System.out.println("Consumo Memoria A*: " + longitud_maxima);
		System.out.println("Cargando el plan...");
		printPath();
		long tFinal = System.nanoTime();
		long tiempoTotalEnSegundos = (tFinal - tInicio)/1000000;
		System.out.println("Tiempo Ejecución A*: " + tiempoTotalEnSegundos);
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
    	}
    	return path.poll();

        
    }

}