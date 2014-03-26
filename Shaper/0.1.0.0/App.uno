using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Scenes.Primitives;
using Uno.Content;
using Uno.Content.Models;
using Uno.Math;
using Uno.Collections.EnumerableExtensions;

namespace Shaper
{
    public class App : Uno.Application
    {
		public List<ControlPoint> ControlPoints = new List<ControlPoint>();

		public App()
		{
			var p = float2(150);
			var s = float2(1.0f);
			var r = 100.0f*1.0f;
			var tr = 100.0f*0.55f;

			ControlPoints.Add(new ControlPoint { Position = p+float2(r,0)*s, TangentLeft = p+float2(r,tr)*s, TangentRight = p+float2(r,-tr)*s });
			ControlPoints.Add(new ControlPoint { Position = p+float2(0,-r)*s, TangentLeft = p+float2(tr,-r)*s, TangentRight = p+float2(-tr,-r)*s });
			ControlPoints.Add(new ControlPoint { Position = p+float2(-r,0)*s, TangentLeft = p+float2(-r,-tr)*s, TangentRight = p+float2(-r,tr)*s });
			ControlPoints.Add(new ControlPoint { Position = p+float2(0,r)*s, TangentLeft = p+float2(-tr,r)*s, TangentRight = p+float2(tr,r)*s });
			ControlPoints.Add(new ControlPoint { Position = p+float2(r,0)*s, TangentLeft = p+float2(r,tr)*s, TangentRight = p+float2(r,-tr)*s });

			Window.PointerDown += OnPointerDown;
			Window.PointerMove += OnPointerMove;
			Window.PointerUp += OnPointerUp;
		}

        public override void Draw()
        {
			//var circle = new Circle(Scale: s, Radius: 100.0f, Position: p)
			//	.Union(new Circle());
			//circle.Draw();

			var polygon = CurveSubdivision.CreatePolygon(ControlPoints.ToArray());

			var _vertices = ToArray(polygon);

			draw
			{
				PrimitiveType : PrimitiveType.LineStrip;
				PointSize:2.0f;
				float2 VertexPosition : vertex_attrib(_vertices);
				ClipPosition: float4(VertexPosition,0,1);
				PixelColor: float4(0,1,1,1);
				ClipPosition : float4(((prev.XY / Context.Viewport.Size) * 2 - 1) * float2(1,-1), -1, 1);
				CullFace : PolygonFace.None;
			};

			try
			{
				var _indices = ToArray(PolygonTriangulation.CreateTriangles(polygon));

				draw
				{
					float2 VertexPosition : vertex_attrib(_vertices, _indices);
					ClipPosition: float4(VertexPosition,0,1);
					PixelColor: float4(0,0.1f,0.3f,1);
					ClipPosition : float4(((prev.XY / Context.Viewport.Size) * 2 - 1) * float2(1,-1), -1, 1);
					CullFace : PolygonFace.None;
				};
			}
			catch (Exception e)
			{
			}
			DrawGizmos();
		}


		void DrawGizmos()
		{
			foreach (var point in ControlPoints)
			{
				CircleRenderer.Draw(point.TangentLeft, 5.0f);
				DrawLine(point.Position, point.TangentLeft);
				CircleRenderer.Draw(point.Position, 10.0f);
				DrawLine(point.Position, point.TangentRight);
				CircleRenderer.Draw(point.TangentRight, 5.0f);
			}
		}

		void DrawLine(float2 from, float2 to)
		{
			var vertices = new float2[] {from, to};
			draw
			{
				PrimitiveType : PrimitiveType.Lines;
				PointSize: 2.0f;
				float2 VertexPosition : vertex_attrib(vertices);
				ClipPosition: float4(VertexPosition,0,1);
				PixelColor: float4(0,1,1,1);
				ClipPosition : float4(((prev.XY / Context.Viewport.Size) * 2 - 1) * float2(1,-1), -1, 1);
				CullFace : PolygonFace.None;
			};
		}


		State _state = new Idle();

		void OnPointerDown(object sender, Uno.Platform.PointerEventArgs args)
		{
			SetState(_state.OnPointerDown(args.Position));
		}
		void OnPointerMove(object sender, Uno.Platform.PointerEventArgs args)
		{
			SetState(_state.OnPointerMove(args.Position));
		}
		void OnPointerUp(object sender, Uno.Platform.PointerEventArgs args)
		{
			SetState(_state.OnPointerUp(args.Position));
		}

		void SetState(State newState)
		{
			_state = newState;
			_state.Context = this;
		}
    }

	class State
	{
		public App Context { get; set; }

		public virtual State OnPointerDown(float2 p) { return this; }
		public virtual State OnPointerMove(float2 p) { return this; }
		public virtual State OnPointerUp(float2 p) { return this; }
	}

	class Idle : State
	{
		public override State OnPointerDown(float2 p)
		{
			foreach (var point in Context.ControlPoints)
			{
				if (Vector.Length(point.Position - p) < 10.0f)
					return new MovingPoint(point);
				if (Vector.Length(point.TangentLeft - p) < 5.0f)
					return new MovingLeft(point);
				if (Vector.Length(point.TangentRight - p) < 5.0f)
					return new MovingRight(point);
			}
			/*for (int i = 0; i<Context.ControlPoints.Length-1; i++)
			{
				var a = Context.ControlPoints[i];
				var b = Context.ControlPoints[i+1];



			}*/
			return this;
		}
	}

	class MovingPoint : State
	{
		public ControlPoint _point;

		public MovingPoint(ControlPoint point)
		{
			_point = point;
		}

		public override Shaper.State OnPointerMove(float2 p)
		{
			var delta = p - _point.Position;
			_point.Position += delta;
			_point.TangentLeft += delta;
			_point.TangentRight += delta;
			return this;
		}

		public override State OnPointerUp(float2 p)
		{
			return new Idle();
		}
	}

	class MovingLeft : State
	{
		public ControlPoint _point;

		public MovingLeft(ControlPoint point)
		{
			_point = point;
		}

		public override Shaper.State OnPointerMove(float2 p)
		{
			var delta = p - _point.TangentLeft;
			_point.TangentLeft += delta;
			_point.TangentRight = _point.Position + (_point.Position - _point.TangentLeft);
			return this;
		}

		public override State OnPointerUp(float2 p)
		{
			return new Idle();
		}
	}

	class MovingRight : State
	{
		public ControlPoint _point;

		public MovingRight(ControlPoint point)
		{
			_point = point;
		}

		public override Shaper.State OnPointerMove(float2 p)
		{
			var delta = p - _point.TangentRight;
			_point.TangentRight += delta;
			_point.TangentLeft = _point.Position + (_point.Position - _point.TangentRight);
			return this;
		}

		public override State OnPointerUp(float2 p)
		{
			return new Idle();
		}
	}
}