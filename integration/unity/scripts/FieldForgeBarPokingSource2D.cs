using Unity.Mathematics;
using UnityEngine;

namespace FieldForge
{
    public class FieldForgeBarPokingSource2D : SimulationInteractiveBehavior
    {
        [SerializeField, Min(0)] int pokeStrength = 1000;
        [SerializeField, Min(1)] int pulseDuration = 1;
        [SerializeField, Min(0)] int pulseCooldown = 0;
        [SerializeField] SerializableFieldsMask pokeMask;

        private RectTransform _rectTransform;

        private Vector2 _simulationSize;
        private Vector2 _screenSize;

        private int _pulseFrameCounter = 0;

        private void Start()
        {
            _rectTransform = GetComponent<RectTransform>();
            SimulationData simulationData = simulationManager.simulationInterface.simulationData;
            _simulationSize = new Vector2(simulationData.simulationWidth, simulationData.simulationHeight);
            _screenSize = new Vector2(Screen.width, Screen.height);
            _pulseFrameCounter = 0;
        }

        private void Update()
        {
            // if (_pulseFrameCounter > 0) SubmitCurrentPoke();
            // if (_pulseFrameCounter > pulseDuration) _pulseFrameCounter = -pulseCooldown;
            _pulseFrameCounter++;
            SubmitCurrentPoke();
        }

        private void SubmitCurrentPoke()
        {
            SimulationPokeInformation pokeInformation = ConstructCurrentPoke();
            simulationManager.PokesManager.SubmitPoke(pokeInformation);
        }

        private SimulationPokeInformation ConstructCurrentPoke()
        {
            Vector2 pokingDelta = GetScreenSpaceDelta() / _screenSize * _simulationSize;
            Vector2 pokingPosition = GetScreenSpaceCenter() / _screenSize * _simulationSize + pokingDelta / 2; // > ( / _screenSize * _simulationSize; ) consider having some "simulation scale" parameter
            float pokeRadius = Mathf.Floor(GetScreenSpaceRadius() / _screenSize.x * _simulationSize.x);
            Debug.Log(pokeStrength * math.cos((float)_pulseFrameCounter / pulseCooldown));
            return new SimulationPokeInformation
            {
                pokeStrength = (int)(pokeStrength * math.cos((float)_pulseFrameCounter / pulseCooldown)),
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
            return Mathf.Min((worldCorners[3] - worldCorners[0]).magnitude, (worldCorners[1] - worldCorners[0]).magnitude);
        }

        private Vector2 GetScreenSpaceDelta()
        {
            Vector3[] worldCorners = new Vector3[4];
            _rectTransform.GetWorldCorners(worldCorners);
            Vector2 dir1 = worldCorners[1] - worldCorners[0];
            Vector2 dir2 = worldCorners[3] - worldCorners[0];
            return dir1.sqrMagnitude > dir2.sqrMagnitude ? dir1 : dir2;
        }
    }
}