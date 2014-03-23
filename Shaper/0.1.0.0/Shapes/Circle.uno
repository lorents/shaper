using Uno.Scenes;
using Uno.Graphics;
using Uno.Math;
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
				PixelColor: float4(0,1,0,1);
				ClipPosition : float4(((prev.XY / Context.Viewport.Size) * 2 - 1) * float2(1,-1), -1, 1);
				CullFace : PolygonFace.None;
			};
		}
	}


	public class Circle : Shape
	{
		public float Radius { get; private set; }
		public float2 Position { get; private set; }

		public Circle(float Radius = 10.0f, float2 Position = float2(0)/*, Func<Shape, float> CalcRadius = null, Func<Shape, float2> CalcPosition = null*/)
		{
			this.Radius = Radius;
			this.Position = Position;
		}

		internal override void Draw(DrawContext dc)
		{
			CircleRenderer.Draw(Position, Radius);
		}
	}
}