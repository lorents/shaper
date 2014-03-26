using Uno.Scenes;
using Uno.Graphics;
using Uno.Math;
using Uno.Collections.EnumerableExtensions;
using Uno;

namespace Shaper
{

	public class CircleRenderer
	{
		static CircleRenderer _instance;

		public static void Draw(float2 pos, float r)
		{
			(_instance ?? (_instance = new CircleRenderer())).DrawInstance(pos, r);
		}

		float2[] _vertices;
		ushort[] _indices;

		CircleRenderer()
		{
			var vertexCount = 128;
			_vertices = new float2[vertexCount];
			_indices = new ushort[vertexCount*3];

			for (int v = 0, i = 0; v < vertexCount; v++)
			{
				var f = ((float)v / vertexCount) * Uno.Math.PIf*2;
				_vertices[v] = float2(Cos(f), Sin(f));

				_indices[i++] = 0;
				_indices[i++] = (ushort)((v) % vertexCount);
				_indices[i++] = (ushort)((v+1) % vertexCount);
			}
		}

		void DrawInstance(float2 pos, float r)
		{
			draw
			{
				float2 VertexPosition : vertex_attrib(_vertices, _indices);
				ClipPosition: float4(pos + VertexPosition * r,0,1);
				PixelColor: float4(1,1,1,1);
				ClipPosition : float4(((prev.XY / Context.Viewport.Size) * 2 - 1) * float2(1,-1), -1, 1);
				CullFace : PolygonFace.None;
			};
		}
	}


	public class Circle : Shape
	{
		public float Radius { get; private set; }
		public Func<Tweener, float> EvalRadius { get; private set; }
		
		public Circle(
			double TimeOffset = 0,
			float2 Position = float2(0), Func<Tweener, float2> EvalPosition = null,
			float2 Scaling = float2(1), Func<Tweener, float2> EvalScaling = null,
			float Radius = 10.0f, Func<Tweener, float> EvalRadius = null)
			: base(TimeOffset, Position, EvalPosition, Scaling, EvalScaling)
		{
			this.Radius = Radius;
			this.EvalRadius = EvalRadius;
		}

		public Circle Animate(
			Func<Tweener, float2> Position = null,
			Func<Tweener, float2> Scaling = null,
			Func<Tweener, float> Radius = null)
		{
			return new Circle(
				this.TimeOffset, 
				this.Position, Position != null ? Position : this.EvalPosition, 
				this.Scaling, Scaling != null ? Scaling : this.EvalScaling, 
				this.Radius, Radius != null ? Radius : this.EvalRadius);
		}
		
		public override Shape Delay(double offset)
		{
			return new Circle(
				offset, 
				this.Position, this.EvalPosition, 
				this.Scaling, this.EvalScaling, 
				this.Radius, this.EvalRadius);
		}
		
		public override Shape Translate(float2 offset)
		{
			return new Circle(
				this.TimeOffset, 
				this.Position + offset, this.EvalPosition == null ? this.EvalPosition : new Offset(this.EvalPosition, offset).Evaluate, 
				this.Scaling, this.EvalScaling, 
				this.Radius, this.EvalRadius);
		}
		
		class Offset 
		{
			readonly Func<Tweener, float2> _eval;
			readonly float2 _offset;
			
			public Offset(Func<Tweener, float2> eval, float2 offset)
			{
				_eval = eval;
				_offset = offset;
			}
			
			public float2 Evaluate(Tweener t)
			{
				return _eval(t) + _offset;
			}
		}
		
		internal override void Draw(DrawContext dc, double time)
		{
			var tweener = new Tweener(time + TimeOffset);
			var p = EvalOrUse(EvalPosition, Position, tweener);
			var s = EvalOrUse(EvalScaling, Scaling, tweener);
			var r = EvalOrUse(EvalRadius, Radius, tweener);
			var tr = r * 0.55f;
			var polygon = CurveSubdivision.CreatePolygon(
				new ControlPoint { Position = p+float2(r,0)*s, TangentLeft = p+float2(r,tr)*s, TangentRight = p+float2(r,-tr)*s },
				new ControlPoint { Position = p+float2(0,-r)*s, TangentLeft = p+float2(tr,-r)*s, TangentRight = p+float2(-tr,-r)*s },
				new ControlPoint { Position = p+float2(-r,0)*s, TangentLeft = p+float2(-r,-tr)*s, TangentRight = p+float2(-r,tr)*s },
				new ControlPoint { Position = p+float2(0,r)*s, TangentLeft = p+float2(-tr,r)*s, TangentRight = p+float2(tr,r)*s },
				new ControlPoint { Position = p+float2(r,0)*s, TangentLeft = p+float2(r,tr)*s, TangentRight = p+float2(r,-tr)*s }
			);

			var _vertices = ToArray(polygon);

			draw
			{
				PrimitiveType : PrimitiveType.LineStrip;
				PointSize:2.0f;
				float2 VertexPosition : vertex_attrib(_vertices);
				ClipPosition: float4(VertexPosition + float2(200),0,1);
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
					ClipPosition: float4(VertexPosition + float2(200),0,1);
					PixelColor: float4(0,0,0.2f,1);
					ClipPosition : float4(((prev.XY / Context.Viewport.Size) * 2 - 1) * float2(1,-1), -1, 1);
					CullFace : PolygonFace.None;
				};
			}
			catch (Uno.Exception e)
			{
			}
		}
		T EvalOrUse<T, Targ>(Func<Targ, T> eval, T constant, Targ arg)
		{
			return eval != null ? eval(arg) : constant;
		}
		
	}
}