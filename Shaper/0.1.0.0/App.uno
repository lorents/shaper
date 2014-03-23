using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Scenes.Primitives;
using Uno.Content;
using Uno.Content.Models;

namespace Shaper
{
    public class App : Uno.Application
    {
		Shape _shape;

		public App()
		{
			var circle = new Circle(Radius: 50, Position: float2(150,100));
			var innerCircle = new Circle(Radius: 40.0f, Position: float2(100,100));//circle.Animate(Position: s => Tan(_time));

			_shape = circle.Subtract(innerCircle);

			
					

		}

		
        public override void Draw()
        {
			//_shape.Draw();
			float2[] _vertices;
			ushort[] _indices;

			var a = new List<float2>();

			var vertexCount = 1000;
			for (int v = 0, i = 0; v < vertexCount; v++)
			{
				var f = ((float)v / vertexCount) * Uno.Math.PIf*2;
				var b = (float)Math.Sin(FrameTime*2.0 + f*10.0f) * 0.2f + 1.0f;
				var p = float2(Math.Cos(f), Math.Sin(f));
				a.Add(p * b * 200.0f * Math.Max(0.3f,p.Y*2.0f));
			}
			
			var result = new List<ushort>();
			Triangulate.Process(a, result);			

			_vertices = a.ToArray();
			_indices = result.ToArray();
					
			draw
			{
				PrimitiveType : PrimitiveType.Points;
				PointSize:2.0f;
				float2 VertexPosition : vertex_attrib(_vertices);
				ClipPosition: float4(VertexPosition + float2(200),0,1);
				PixelColor: float4(0,1,1,1);
				ClipPosition : float4(((prev.XY / Context.Viewport.Size) * 2 - 1) * float2(1,-1), -1, 1);
				CullFace : PolygonFace.None;
			};

			
			draw
			{
				float2 VertexPosition : vertex_attrib(_vertices, _indices);
				ClipPosition: float4(VertexPosition + float2(200),0,1);
				PixelColor: float4(0,0,0.2f,1);
				ClipPosition : float4(((prev.XY / Context.Viewport.Size) * 2 - 1) * float2(1,-1), -1, 1);
				CullFace : PolygonFace.None;
			};
        }
    }
}