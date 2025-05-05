using System;
using UnityEngine;

namespace FieldForge
{
    [Serializable]
    public class FermionFields
    {
        public bool Fermion1 = false;
        public bool Fermion2 = false;
        public bool Fermion3 = false;
        public bool Fermion4 = false;
        public bool Fermion5 = false;
        public bool Fermion6 = false;
        public bool Fermion7 = false;
        public bool Fermion8 = false;
    }

    [Serializable]
    public class GaugeSymmetries
    {
        public bool U1 = false;
        public bool SU2_1 = false;
        public bool SU2_2 = false;
        public bool SU2_3 = false;
        public bool SU3_1 = false;
        public bool SU3_2 = false;
        public bool SU3_3 = false;
        public bool SU3_4 = false;
        public bool SU3_5 = false;
        public bool SU3_6 = false;
        public bool SU3_7 = false;
        public bool SU3_8 = false;
    }

    [Serializable]
    public class SerializableFieldsMask
    {
        public FermionFields fermionFields;
        public GaugeSymmetries gaugeSymmetries;

        public int Binary
        {
            get
            {
                int mask = 0;
                if (fermionFields.Fermion1) mask |= 1 << 0;
                if (fermionFields.Fermion2) mask |= 1 << 1;
                if (fermionFields.Fermion3) mask |= 1 << 2;
                if (fermionFields.Fermion4) mask |= 1 << 3;
                if (fermionFields.Fermion5) mask |= 1 << 4;
                if (fermionFields.Fermion6) mask |= 1 << 5;
                if (fermionFields.Fermion7) mask |= 1 << 6;
                if (fermionFields.Fermion8) mask |= 1 << 7;
                if (gaugeSymmetries.U1) mask |= 1 << 8;
                if (gaugeSymmetries.SU2_1) mask |= 1 << 9;
                if (gaugeSymmetries.SU2_2) mask |= 1 << 10;
                if (gaugeSymmetries.SU2_3) mask |= 1 << 11;
                if (gaugeSymmetries.SU3_1) mask |= 1 << 12;
                if (gaugeSymmetries.SU3_2) mask |= 1 << 13;
                if (gaugeSymmetries.SU3_3) mask |= 1 << 14;
                if (gaugeSymmetries.SU3_4) mask |= 1 << 15;
                if (gaugeSymmetries.SU3_5) mask |= 1 << 16;
                if (gaugeSymmetries.SU3_6) mask |= 1 << 17;
                if (gaugeSymmetries.SU3_7) mask |= 1 << 18;
                if (gaugeSymmetries.SU3_8) mask |= 1 << 19;
                return mask;
            }
            set
            {
                fermionFields.Fermion1 = (value & (1 << 0)) != 0;
                fermionFields.Fermion2 = (value & (1 << 1)) != 0;
                fermionFields.Fermion3 = (value & (1 << 2)) != 0;
                fermionFields.Fermion4 = (value & (1 << 3)) != 0;
                fermionFields.Fermion5 = (value & (1 << 4)) != 0;
                fermionFields.Fermion6 = (value & (1 << 5)) != 0;
                fermionFields.Fermion7 = (value & (1 << 6)) != 0;
                fermionFields.Fermion8 = (value & (1 << 7)) != 0;
                gaugeSymmetries.U1 = (value & (1 << 8)) != 0;
                gaugeSymmetries.SU2_1 = (value & (1 << 9)) != 0;
                gaugeSymmetries.SU2_2 = (value & (1 << 10)) != 0;
                gaugeSymmetries.SU2_3 = (value & (1 << 11)) != 0;
                gaugeSymmetries.SU3_1 = (value & (1 << 12)) != 0;
                gaugeSymmetries.SU3_2 = (value & (1 << 13)) != 0;
                gaugeSymmetries.SU3_3 = (value & (1 << 14)) != 0;
                gaugeSymmetries.SU3_4 = (value & (1 << 15)) != 0;
                gaugeSymmetries.SU3_5 = (value & (1 << 16)) != 0;
                gaugeSymmetries.SU3_6 = (value & (1 << 17)) != 0;
                gaugeSymmetries.SU3_7 = (value & (1 << 18)) != 0;
                gaugeSymmetries.SU3_8 = (value & (1 << 19)) != 0;
            }
        }
    }
}
