using System;
using UnityEngine;


namespace FieldForge
{
    public class PokesManager
    {
        private int _submittedPokesCount, _appliedPokesCount;
        private SimulationPokeInformation[] _submittedPokes;

        private readonly ComputeManager _computeManager;

        public PokesManager(ComputeManager computeManager)
        {
            _computeManager = computeManager;
            ClearPokes();
        }

        public void SubmitPoke(SimulationPokeInformation poke)
        {
            if (_submittedPokesCount >= _submittedPokes.Length)
            {
                Debug.LogWarning("Max pokes reached, poke was not submitted.");
                return;
            }
            _submittedPokes[_submittedPokesCount] = poke;
            _submittedPokesCount++;
        }

        public void ApplyPokes()
        {
            if (_submittedPokesCount == 0 && _appliedPokesCount == 0) return;
            ComputeBuffers computeBuffers = _computeManager.GetBuffers();
            computeBuffers.SimulationPokesBuffer.SetData(_submittedPokes, 0, 0, Math.Max(_submittedPokesCount, _appliedPokesCount));
            _appliedPokesCount = _submittedPokesCount;
            ClearPokes();
        }

        public void ClearPokes()
        {
            _submittedPokesCount = 0;
            _submittedPokes = new SimulationPokeInformation[16];
        }
    }
}
