using UnityEngine;

namespace FieldForge
{
    public class FieldForgeBarBarrier2D : SimulationInteractiveBehavior
    {
        [SerializeField] uint barrierStrength = 1;
        [SerializeField] float barrierRadius = 0f;
        [SerializeField] private SerializableFieldsMask barrierMask;

        private RectTransform _rectTransform;

        private Vector2 _simulationSize;
        private Vector2 _screenSize;

        private void Start()
        {
            _rectTransform = GetComponent<RectTransform>();
            SimulationData simulationData = simulationManager.simulationInterface.simulationData;
            _simulationSize = new Vector2(simulationData.simulationWidth, simulationData.simulationHeight);
            _screenSize = new Vector2(Screen.width, Screen.height);
        }

        private void Update()
        {
            SubmitCurrentBarrier();
        }

        private void SubmitCurrentBarrier()
        {
            SimulationBarrierInformation barrierInformation = ConstructCurrentBarrier();
            simulationManager.BarriersManager.SubmitBarrier(barrierInformation);
        }

        private SimulationBarrierInformation ConstructCurrentBarrier()
        {
            Vector2 simulationSpaceDelta = GetScreenSpaceDelta() / _screenSize * _simulationSize;
            Vector2 simulationSpaceCenter = GetScreenSpaceCenter() / _screenSize * _simulationSize;
            Vector2 simulationSpacePoint1 = simulationSpaceCenter - simulationSpaceDelta / 2;
            Vector2 simulationSpacePoint2 = simulationSpaceCenter + simulationSpaceDelta / 2;
            float simulationSpaceWidth = GetScreenSpaceWidth() / _screenSize.x * _simulationSize.x;
            return new SimulationBarrierInformation
            {
                barrierStrength = (int)barrierStrength,
                barrierWidth = (int)simulationSpaceWidth,
                barrierRadius = (int)barrierRadius,
                p1_x = (int)simulationSpacePoint1.x,
                p1_y = (int)simulationSpacePoint1.y,
                p1_z = 0,
                p2_x = (int)simulationSpacePoint2.x,
                p2_y = (int)simulationSpacePoint2.y,
                p2_z = 0,
                barrierMask = barrierMask.Binary
            };
        }

        private Vector2 GetScreenSpaceCenter()
        {
            Vector3[] worldCorners = new Vector3[4];
            _rectTransform.GetWorldCorners(worldCorners);
            return (worldCorners[0] + worldCorners[2]) * 0.5f;
        }

        private float GetScreenSpaceWidth()
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