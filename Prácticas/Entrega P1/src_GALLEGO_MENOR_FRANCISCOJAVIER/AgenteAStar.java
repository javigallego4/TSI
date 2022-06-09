package tracks.singlePlayer.evaluacion.src_GALLEGO_MENOR_FRANCISCOJAVIER; 

import java.util.ArrayList;
import java.util.Collections;
import java.util.Deque;
import java.util.LinkedHashSet;
import java.util.ArrayDeque;
import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

public class AgenteAStar extends AbstractPlayer {
	Nodo initial_node, objective_node;
	int expandedNodes = 0;
	Vector2d scale;
	Deque<Types.ACTIONS> path = new ArrayDeque<>();
	static boolean pathFound = false;	

    /**
     * Public constructor. We initialize both initial and final nodes, as well as scale.
     * @param stateObs state observation of the current game.
     * @param elapsedTimer Timer for the controller creation.
     */
    public AgenteAStar(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
    {
    	scale = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length ,
                stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);
    	initial_node = new Nodo(new Vector2d(stateObs.getAvatarPosition().x / scale.x, stateObs.getAvatarPosition().y / scale.y), stateObs);
    	objective_node = new Nodo(new Vector2d(stateObs.getPortalsPositions()[0].get(0).position.x/scale.x, stateObs.getPortalsPositions()[0].get(0).position.y / scale.y), stateObs);    	
		/**
		 * We never make use of initial node's parent. Therefore, in order to prevent line 132 NullPointerException, we initialize it to whenever node we want.
		 */
		initial_node.parent = objective_node;
    }    	

	/**
     * Respective actions, our avatar has to make in order to reach objective node. As we have saved parent attribute of each node, we just have to compare both
	 * current and parent node positions. Thus, we'll obtain which action has to be made. We start from the objective node. 
     */
    void pathActions() {
    	Nodo current = objective_node;    	    
    	
    	while (current != initial_node) {

    		Nodo parent = current.parent;
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

	/**
     * This function has the aim of finding the path to the final objective node. We follow the pseudocode given on the slides.
     * @param stateObs: state observation of the current game.
     * @param objective_node: final objective node. 
     */
	public void pathFinder(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {		
		long tInicio = System.nanoTime();
		ArrayList<Nodo> openedList = new ArrayList<Nodo>();
		ArrayList<Nodo> closedList = new ArrayList<Nodo>();
		int maxLength = 0;
				
		Nodo current; 
		ArrayList<Nodo> neighbours; 								        
		LinkedHashSet<Double> obstacles = getObstacles(stateObs);
		int index;
				
		initial_node.heuristicValue = distManhattan(initial_node, objective_node);
		openedList.add(initial_node);
		
		while (true) {
			if(openedList.size() + closedList.size() > maxLength) {
				maxLength = openedList.size() + closedList.size();
			}
			// Ordenamos openedList según f(n)			
			Collections.sort(openedList);
			// Primer elemento de openedList es el mejor candidato
			current = openedList.get(0);
			expandedNodes += 1;
						
			// Comprobamos si estamos en el nodo objective_node
			if(current.equals(objective_node)) {
				objective_node.parent = current.parent;
				break;
			}
			
			/* Puesto que estamos visitando 'current', lo eliminamos de openedList
			y lo añadimos a closedList*/
			openedList.remove(current);
			closedList.add(current);
			
			// Obtenemos vecinos del nodo 'current'
			neighbours = current.neighboursAStar(objective_node, stateObs);

			for(Nodo vecino : neighbours) {
				// Si el nodo vecino es válido y no es un obstáculo
				if(isValid(stateObs, vecino)  && !obstacles.contains(vecino.ID)) {
					// Si ya hemos visitado el nodo parent -> Pass
					if(!vecino.equals(current.parent)) {
						/*
						 * Si ya hemos visitado este nodo, pero el padre no (equivalente a no haber explorado esta ruta, que es distinta)
						 * Comparamos los costes obtenidos en cada camino realizado, y nos quedamos con el mejor
						 */						
						if (closedList.contains(vecino)){							
							index = closedList.indexOf(vecino);							
							/*
							 *  Si el coste actual del vecino es menor que el valor previo, entonces la ruta actual hasta el nodo
							 *  vecino es mejor que la anterior. Por tanto, actualizamos valores.
							*/
							if(closedList.get(index).currentCost > vecino.currentCost) {
								closedList.remove(index);
								/*
								 *  Como el vecino está en closedList (nodos ya visitados), no está en openedList.
								 *  Lo eliminamos de closedList, y añadimos en la lista de openedList para actualizar su g(n)
								*/
								openedList.add(vecino);
							}
						}
						
						/*
						 *  Si es la 1ª vez que nos encontramos con el nodo, pues no está ni en la lista de nodos pendientes
						 *  de visitar, lo añadimos a esta.
						*/
						else if(!closedList.contains(vecino) && !openedList.contains(vecino)) {
								openedList.add(vecino);
						}
						
						/*
						 * Si el nodo sucesor se encuentra pendiente de visitar y obtenemos una mejor ruta para llegar hasta él,
						 * actualizamos valores.
						 */
						else if(openedList.contains(vecino)) {
							index = openedList.indexOf(vecino);
	
							if(openedList.get(index).currentCost > vecino.currentCost) {
								openedList.get(index).currentCost = vecino.currentCost;
							}							
						}											
					}
				}
			}			
		}				
		
		System.out.println("Nodos expandidos A*: " + expandedNodes);
		System.out.println("Consumo Memoria A*: " + maxLength);
		System.out.println("Cargando el plan...");
		pathActions();
		long tFinal = System.nanoTime();
		long tiempoTotalEnSegundos = (tFinal - tInicio)/1000000;
		System.out.println("Tiempo Ejecución A*: " + tiempoTotalEnSegundos);
	}

    /**
     * If we have not found the path yet, we find it. If this is not the case, we just return next action avatar's gonna make
     * @param stateObs state observation of the current game.
     * @param elapsedTimer timer.
     * @return next action to make
     */
	public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
    	if (!pathFound) {
    		pathFinder(stateObs, elapsedTimer);
    		pathFound = true;
    	}
    	return path.poll();        
    }
    
	/**
     * We are going to use Manhattan distance for heuristic values.
	 * @param n1 first node.
     * @param n2 second node. In our case, it's always going to be objective node
     */
	public double distManhattan(Nodo n1, Nodo n2){
    	return Math.abs(n1.posicion.x-n2.posicion.x) + Math.abs(n1.posicion.y-n2.posicion.y);
    }
    
	/**
     * Getting obstacles.
     * @param stateObs state observation of the current game.
     * @return LinkedHashSet with every obstacle in map, including both walls and spikes.
     */
    public LinkedHashSet<Double> getObstacles(StateObservation stateObs) {
		LinkedHashSet<Double> obstacles = new LinkedHashSet<>();
		ArrayList<Observation>[] immovablePositions = stateObs.getImmovablePositions();
		
		// Añadimos los IDs correspondientes a los obstacles
	    for(Observation obs : immovablePositions[0])
	    	obstacles.add( Math.floor(obs.position.x / scale.x) + stateObs.getObservationGrid().length * Math.floor(obs.position.y / scale.y));
	    
	    for(Observation obs : immovablePositions[1])
	    	obstacles.add( Math.floor(obs.position.x / scale.x) + stateObs.getObservationGrid().length * Math.floor(obs.position.y / scale.y));
	    	    
	    return obstacles;
	}
    
	/**
     * Check whether the given node is valid or not.
     * @param stateObs: state observation of the current game.
	 * @param node: node for which we are gonna check validity
     * @return Whether the given node is valid or not.
     */
    public boolean isValid(StateObservation stateObs, Nodo node) {
    	if(	node.posicion.x < stateObs.getObservationGrid().length 
    		&& node.posicion.y < stateObs.getObservationGrid()[0].length ){
    			return true;
    		}
    	return false;
    }    	
}