using UnityEngine;

namespace FieldForge
{
    /// <summary>
    /// A script allowing a UI element in a canvas to represent a point poking source in the simulation.
    /// This script should be attached to a UI element in a Canvas.
    /// Would poke the simulation at the center position of the UI element,
    /// with a radius equaling half of the smallest size component of the UI element.
    /// </summary>
    [RequireComponent(typeof(RectTransform))]
    public class FieldForgePointPokingSource2D : SimulationInteractiveBehavior
    {
        [SerializeField, Min(0)] int pokeStrength = 1000;
        [SerializeField, Min(1)] int pulseDuration = 1;
        [SerializeField, Min(0)] int pulseCooldown = 0;
        [SerializeField] SerializableFieldsMask pokeMask;

        private RectTransform _rectTransform;

        private Vector2 _centerScreenPosition;
        private Vector2 _centerScreenDeltaPosition;
        private Vector2 _simulationSize;
        private Vector2 _screenSize;

        private int _pulseFrameCounter = 0;

        private bool _firstFrame = true;

        private void Start()
        {
            _rectTransform = GetComponent<RectTransform>();
            SimulationData simulationData = simulationManager.simulationInterface.simulationData;
            _simulationSize = new Vector2(simulationData.simulationWidth, simulationData.simulationHeight);
            _screenSize = new Vector2(Screen.width, Screen.height);
        }

        private void Update()
        {
            _centerScreenDeltaPosition = GetScreenSpaceCenter() - _centerScreenPosition;
            _centerScreenPosition += _centerScreenDeltaPosition;
            if (!_firstFrame && _pulseFrameCounter > 0) SubmitCurrentPoke();
            if (_pulseFrameCounter > pulseDuration) _pulseFrameCounter = -pulseCooldown;
            _pulseFrameCounter++;
            _firstFrame = false;
        }

        private void SubmitCurrentPoke()
        {
            SimulationPokeInformation pokeInformation = ConstructCurrentPoke();
            simulationManager.PokesManager.SubmitPoke(pokeInformation);
        }

        private SimulationPokeInformation ConstructCurrentPoke()
        {
            Vector2 pokingPosition = _centerScreenPosition / _screenSize * _simulationSize; // > ( / _screenSize * _simulationSize; ) consider having some "simulation scale" parameter
            Vector2 pokingDelta = _centerScreenDeltaPosition / _screenSize * _simulationSize;
            float pokeRadius = Mathf.Floor(GetScreenSpaceRadius() / _screenSize.x * _simulationSize.x);
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
                pokeMask = pokeMask.Binary
            };
        }

        private Vector2 GetScreenSpaceCenter()
        {
            Vector3[] worldCorners = new Vector3[4];
            _rectTransform.GetWorldCorners(worldCorners);
            return (worldCorners[0] + worldCorners[2]) * 0.5f;
        }

        private float GetScreenSpaceRadius()
        {
            Vector3[] worldCorners = new Vector3[4];
            _rectTransform.GetWorldCorners(worldCorners);
            Vector2 size = worldCorners[2] - worldCorners[0];
            return Mathf.Min(size.x, size.y) / 2;
        }
    }
}