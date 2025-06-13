using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Serialization;

namespace FieldForge
{
    public class TouchPoking2D : SimulationInteractiveBehavior
    {
        [SerializeField] uint pokeStrength = 1000;
        [SerializeField] uint pokeRadius = 3;

        [SerializeField] SerializableFieldsMask touchPokesMask;
        private TouchTracker _touchTracker;
        private float3 _previousSimulationTouchPosition;

        private SimulationData _simulationData;
        private Vector2 _screenSize;

        private void Start()
        {
            _touchTracker = new TouchTracker();
            _simulationData = simulationManager.simulationInterface.simulationData;
            _screenSize = new Vector2(Screen.width, Screen.height);
        }

        private void Update()
        {
            // check if not on mobile
            HandleTouchInputs();
        }

        private void HandleTouchInputs()
        {
            _touchTracker.Update();
            foreach (Touch touch in Input.touches)
            {
                if (touch.phase == TouchPhase.Began || touch.phase == TouchPhase.Moved)
                {
                    if (_touchTracker.IsTouchActive(touch.fingerId))
                    {
                        SimulationPokeInformation pokeInformation = ConstructCurrentPoke(touch.fingerId);
                        simulationManager.PokesManager.SubmitPoke(pokeInformation);
                    }
                }
            }
        }

        private SimulationPokeInformation ConstructCurrentPoke(int fingerId)
        {
            Vector2 simulationSize = new Vector2(_simulationData.simulationWidth, _simulationData.simulationHeight);
            Vector2 pokingPosition = _touchTracker.GetTouchPosition(fingerId) / _screenSize * simulationSize;
            Vector2 pokingDelta = _touchTracker.GetTouchDeltaPosition(fingerId) / _screenSize * simulationSize;
            return new SimulationPokeInformation
            {
                pokeStrength = (int)pokeStrength,
                pokeRadius = (int)pokeRadius,
                x = (int)pokingPosition.x,
                y = (int)pokingPosition.y,
                z = 0,
                dx = (int)pokingDelta.x,
                dy = (int)pokingDelta.y,
                dz = 0,
                pokeMask = touchPokesMask.Binary
            };
        }
    }
}
