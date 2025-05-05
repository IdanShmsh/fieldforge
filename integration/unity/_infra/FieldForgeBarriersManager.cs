using System;
using UnityEngine;


namespace FieldForge
{
    public class BarriersManager
    {
        private int _submittedBarriersCount, _appliedBarriersCount;
        private SimulationBarrierInformation[] _submittedBarriers;

        private readonly ComputeManager _computeManager;

        public BarriersManager(ComputeManager computeManager)
        {
            _computeManager = computeManager;
            ClearBarriers();
        }

        public void SubmitBarrier(SimulationBarrierInformation barrier)
        {
            if (_submittedBarriersCount >= _submittedBarriers.Length)
            {
                Debug.LogWarning("Max barriers reached, barrier was not submitted.");
                return;
            }
            _submittedBarriers[_submittedBarriersCount] = barrier;
            _submittedBarriersCount++;
        }

        public void ApplyBarriers()
        {
            if (_submittedBarriersCount == 0 && _appliedBarriersCount == 0) return;
            ComputeBuffers computeBuffers = _computeManager.GetBuffers();
            computeBuffers.SimulationBarriersBuffer.SetData(_submittedBarriers, 0, 0, Math.Max(_submittedBarriersCount, _appliedBarriersCount));
            _appliedBarriersCount = _submittedBarriersCount;
            ClearBarriers();
        }

        public void ClearBarriers()
        {
            _submittedBarriersCount = 0;
            _submittedBarriers = new SimulationBarrierInformation[16];
        }
    }
}
