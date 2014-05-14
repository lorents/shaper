using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Content;
using Uno.Content.Models;
using Uno.Collections.EnumerableExtensions;
using Uno.UI;

namespace Shaper
{
	/*
		TODO:
		- Invalidate visual only when needed
		- Cache vertex data?
		- Supersampling
		- Proper looping
		- LineTo
		- Designer:
			- Draw outline when selected (?)
			- Selected control points concept
			- Delete control points
			- Add new control points
			- Cursors and hints
	*/

	public class Path : Element
	{
		List<ControlPoint> _controlPoints = new List<ControlPoint>();
		public IList<ControlPoint> ControlPoints { get { return _controlPoints; } }

		public string Data
		{
			get { return PathSerializer.Serialize(_controlPoints); }
			set
			{
				_controlPoints.Clear();
				_controlPoints.AddRange(PathDeserializer.Deserialize(value));
			}
		}

		public Path()
		{
			var p = float2(150);
			var s = float2(1.0f);
			var r = 100.0f*1.0f;
			var tr = 100.0f*0.55f;

			_controlPoints.Add(new ControlPoint { Position = p+float2(r,0)*s, TangentLeft = p+float2(r,tr)*s, TangentRight = p+float2(r,-tr)*s });
			_controlPoints.Add(new ControlPoint { Position = p+float2(0,-r)*s, TangentLeft = p+float2(tr,-r)*s, TangentRight = p+float2(-tr,-r)*s });
			_controlPoints.Add(new ControlPoint { Position = p+float2(-r,0)*s, TangentLeft = p+float2(-r,-tr)*s, TangentRight = p+float2(-r,tr)*s });
			_controlPoints.Add(new ControlPoint { Position = p+float2(0,r)*s, TangentLeft = p+float2(-tr,r)*s, TangentRight = p+float2(tr,r)*s });
			_controlPoints.Add(new ControlPoint { Position = p+float2(r,0)*s, TangentLeft = p+float2(r,tr)*s, TangentRight = p+float2(r,-tr)*s });
		}

		protected override void OnHitTest(HitTestArgs args)
		{
			var polygon = CurveSubdivision.CreatePolygon(_controlPoints);
			var _vertices = ToArray(polygon);
			var p = FromAbsolute(args.PointCoord);
			try
			{
				var _indices = ToArray(PolygonTriangulation.CreateTriangles(polygon));

				for (int i = 0; i<_indices.Length-3; i+=3)
				{
					if (TriangleContainsPoint(_vertices[_indices[i]], _vertices[_indices[i+1]], _vertices[_indices[i+2]], p))
					{
						args.Hit(this);
						return;
					}
				}
			}
			catch (Exception e)
			{
				debug_log "exception: " + e;
			}
		}

		static bool TriangleContainsPoint(float2 A, float2 B, float2 C, float2 P)
		{
			var v0 = C - A;
			var v1 = B - A;
			var v2 = P - A;
			var dot00 = Vector.Dot(v0, v0);
			var dot01 = Vector.Dot(v0, v1);
			var dot02 = Vector.Dot(v0, v2);
			var dot11 = Vector.Dot(v1, v1);
			var dot12 = Vector.Dot(v1, v2);
			var invDenom = 1.0f / (dot00 * dot11 - dot01 * dot01);
			var u = (dot11 * dot02 - dot01 * dot12) * invDenom;
			var v = (dot00 * dot12 - dot01 * dot02) * invDenom;
			return (u >= 0) && (v >= 0) && (u + v < 1);
		}

		public void DrawOutline(float2 origin)
		{
			InvalidateVisual();

			var polygon = CurveSubdivision.CreatePolygon(_controlPoints);
			var _vertices = ToArray(polygon);

			if (_vertices.Length < 3) return;

			draw
			{
				PrimitiveType : PrimitiveType.LineStrip;
				PointSize:2.0f;
				float2 VertexPosition : vertex_attrib(_vertices);
				ClipPosition: float4(VertexPosition,0,1);
				PixelColor: float4(1,1,1,0.8f);
				ClipPosition : float4((((origin + prev.XY) / Context.Viewport.Size) * 2 - 1) * float2(1,-1), -1, 1);
				CullFace : PolygonFace.None;
			};
		}

		protected override void OnDraw(float2 origin)
		{
			InvalidateVisual();

			var polygon = CurveSubdivision.CreatePolygon(_controlPoints);
			var _vertices = ToArray(polygon);

			try
			{
				var _indices = ToArray(PolygonTriangulation.CreateTriangles(polygon));
				Uno.Designer.Wireframe.Enable();
				draw
				{
					float2 VertexPosition : vertex_attrib(_vertices, _indices);
					ClipPosition: float4(VertexPosition,0,1);
					PixelColor: Color;
					ClipPosition : float4((((origin + prev.XY) / Context.VirtualResolution) * 2 - 1) * float2(1,-1), -1, 1);
					CullFace : PolygonFace.None;
				};
				Uno.Designer.Wireframe.Disable();

			}
			catch (Exception e)
			{
			}
		}
	}
}