using Unity.Mathematics;
using UnityEngine;

namespace FieldForge
{
    public class MousePoking2D : SimulationInteractiveBehavior
    {
        [SerializeField] uint pokeStrength = 1000;
        [SerializeField] uint pokeRadius = 3;

        [SerializeField] SerializableFieldsMask mousePokesMask;
        private MouseTracker _mouseTracker;
        private float3 _previousSimulationTouchPosition;

        private Vector2 _simulationSize;
        private Vector2 _screenSize;

        private void Start()
        {
            _mouseTracker = new MouseTracker();
            SimulationData simulationData = simulationManager.simulationInterface.simulationData;
            _simulationSize = new Vector2(simulationData.simulationWidth, simulationData.simulationHeight);
            _screenSize = new Vector2(Screen.width, Screen.height);
        }

        private void Update()
        {
            // check if not on mobile
            HandleMouseInputs();
        }

        private void HandleMouseInputs()
        {
            _mouseTracker.Update();
            if (!_mouseTracker.IsMouseDown) return;
            SimulationPokeInformation pokeInformation = ConstructCurrentPoke();
            simulationManager.PokesManager.SubmitPoke(pokeInformation);
        }

        private SimulationPokeInformation ConstructCurrentPoke()
        {
            if (!_mouseTracker.IsMouseDown) return default;
            Vector2 pokingPosition = _mouseTracker.MouseDownPosition / _screenSize * _simulationSize;
            Vector2 pokingDelta = _mouseTracker.MouseDownDeltaPosition / _screenSize * _simulationSize;
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
                pokeMask = mousePokesMask.Binary
            };
        }
    }
}
