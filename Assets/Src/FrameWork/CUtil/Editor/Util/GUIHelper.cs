using System;
using UnityEditor;
using UnityEngine;

public static class GUIHelper
{
    public class Horizontal : IDisposable
    {
        public Horizontal(params GUILayoutOption[] options)
        {
            EditorGUILayout.BeginHorizontal(options);
        }

        public Horizontal(out Rect rect, params GUILayoutOption[] options)
        {
            rect = EditorGUILayout.BeginHorizontal(options);
        }

        public Horizontal(GUIStyle style, params GUILayoutOption[] options)
        {
            EditorGUILayout.BeginHorizontal(style, options);
        }

        public Horizontal(out Rect rect, GUIStyle style, params GUILayoutOption[] options)
        {
            rect = EditorGUILayout.BeginHorizontal(style, options);
        }

        public void Dispose()
        {
            EditorGUILayout.EndHorizontal();
        }
    }
    
    public class Vertical : IDisposable
    {
        public Vertical(params GUILayoutOption[] options)
        {
            EditorGUILayout.BeginVertical(options);
        }

        public Vertical(out Rect rect, params GUILayoutOption[] options)
        {
            rect = EditorGUILayout.BeginVertical(options);
        }

        public Vertical(GUIStyle style, params GUILayoutOption[] options)
        {
            EditorGUILayout.BeginVertical(style, options);
        }

        public Vertical(out Rect rect, GUIStyle style, params GUILayoutOption[] options)
        {
            rect = EditorGUILayout.BeginVertical(style, options);
        }

        public void Dispose()
        {
            EditorGUILayout.EndVertical();
        }
    }
    
    public class Scroll
    {
        private Vector2 _position;
        private GUILayoutOption[] options;
        private GUIStyle style;

        public Vector2 position
        {
            get { return this._position; }
        }

        public Scroll(GUIStyle style, params GUILayoutOption[] options)
            : this(options)
        {
            this.style = style;
        }

        public Scroll(params GUILayoutOption[] options)
        {
            this.options = options;
        }

        public GUIHelper.Scroll.ScrollDisposable Start()
        {
            return new GUIHelper.Scroll.ScrollDisposable(ref this._position, this.style, this.options);
        }

        public void ScrollTo(float y = 0.0f)
        {
            this._position.y = y;
        }

        public void ScrollTo(float x = 0.0f, float y = 0.0f)
        {
            this._position.x = x;
            this._position.y = y;
        }

        public class ScrollDisposable : IDisposable
        {
            public ScrollDisposable(
                ref Vector2 position,
                GUIStyle style,
                params GUILayoutOption[] options)
            {
                if (style == null)
                    position = EditorGUILayout.BeginScrollView(position, options);
                else
                    position = EditorGUILayout.BeginScrollView(position, style, options);
            }

            public void Dispose()
            {
                EditorGUILayout.EndScrollView();
            }
        }
    }
}