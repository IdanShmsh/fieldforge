using System.Collections.Generic;
using UnityEngine;


namespace FieldForge
{
    public class TouchTracker
    {
        private Dictionary<int, TouchData> _touches = new Dictionary<int, TouchData>();

        private struct TouchData
        {
            public Vector2 PreviousPosition;
            public Vector2 CurrentPosition;
            public Vector2 DeltaPosition;
        }

        public void Update()
        {
            foreach (var touch in Input.touches)
            {
                if (touch.phase == TouchPhase.Began)
                {
                    _touches[touch.fingerId] = new TouchData
                    {
                        PreviousPosition = touch.position,
                        CurrentPosition = touch.position,
                        DeltaPosition = Vector2.zero
                    };
                }
                else if (touch.phase == TouchPhase.Moved || touch.phase == TouchPhase.Stationary)
                {
                    if (_touches.TryGetValue(touch.fingerId, out var data))
                    {
                        data.PreviousPosition = data.CurrentPosition;
                        data.CurrentPosition = touch.position;
                        data.DeltaPosition = data.CurrentPosition - data.PreviousPosition;
                        _touches[touch.fingerId] = data;
                    }
                }
                else if (touch.phase == TouchPhase.Ended || touch.phase == TouchPhase.Canceled)
                {
                    _touches.Remove(touch.fingerId);
                }
            }
        }

        public bool IsTouchActive(int fingerId) => _touches.ContainsKey(fingerId);

        public Vector2 GetTouchPosition(int fingerId)
        {
            return _touches.TryGetValue(fingerId, out var data) ? data.CurrentPosition : Vector2.zero;
        }

        public Vector2 GetPreviousTouchPosition(int fingerId)
        {
            return _touches.TryGetValue(fingerId, out var data) ? data.PreviousPosition : Vector2.zero;
        }

        public Vector2 GetTouchDeltaPosition(int fingerId)
        {
            return _touches.TryGetValue(fingerId, out var data) ? data.DeltaPosition : Vector2.zero;
        }
    }
}
