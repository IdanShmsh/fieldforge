using System;
using UnityEngine;


namespace FieldForge
{
    public class FermionModesManager
    {
        private int _submittedFermionModesCount, _appliedFermionModesCount;
        private FermionModeData[] _submittedFermionModes;

        private readonly ComputeManager _computeManager;

        public FermionModesManager(ComputeManager computeManager)
        {
            _computeManager = computeManager;
            ClearFermionModes();
        }

        public void SubmitFermionMode(FermionModeData fermionMode)
        {
            if (_submittedFermionModesCount >= _submittedFermionModes.Length)
            {
                Debug.LogWarning("Max fermion modes reached, fermion mode was not submitted.");
                return;
            }
            _submittedFermionModes[_submittedFermionModesCount] = fermionMode;
            _submittedFermionModesCount++;
        }

        public void ApplyFermionModes()
        {
            if (_submittedFermionModesCount == 0 && _appliedFermionModesCount == 0) return;
            ComputeBuffers computeBuffers = _computeManager.GetBuffers();
            computeBuffers.FermionModesBuffer.SetData(_submittedFermionModes, 0, 0, Math.Max(_submittedFermionModesCount, _appliedFermionModesCount));
            _appliedFermionModesCount = _submittedFermionModesCount;
            ClearFermionModes();
        }

        public void ClearFermionModes()
        {
            _submittedFermionModesCount = 0;
            _submittedFermionModes = new FermionModeData[1024];
        }
    }
}
