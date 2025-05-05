using UnityEngine;


namespace FieldForge
{
    public class MouseTracker
    {
        private bool _isMouseDown = false;
        Vector2 _mouseDownPosition = Vector2.zero;
        Vector2 _previousMouseDownPosition = Vector2.zero;
        Vector2 _mouseDownDeltaPosition = Vector2.zero;

        public void Update()
        {
            bool wasMouseDown = _isMouseDown;
            if (Input.GetMouseButtonDown(0)) _isMouseDown = true;
            if (Input.GetMouseButtonUp(0)) _isMouseDown = false;
            if (_isMouseDown)
            {
                _previousMouseDownPosition = _mouseDownPosition;
                _mouseDownPosition = Input.mousePosition;
            }
            _mouseDownDeltaPosition = _isMouseDown && wasMouseDown ? (_mouseDownPosition - _previousMouseDownPosition) : Vector2.zero;
        }

        public Vector2 MouseDownPosition => _mouseDownPosition;
        public Vector2 PreviousMouseDownPosition => _previousMouseDownPosition;
        public Vector2 MouseDownDeltaPosition => _mouseDownDeltaPosition;
        public bool IsMouseDown => _isMouseDown;
    }
}
