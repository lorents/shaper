using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Scenes.Primitives;
using Uno.Content;
using Uno.Content.Models;
using Uno.Math;

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
		
		class ControlPoint
		{
			public float2 Position;
			public float2 TangentRight;
			public float2 TangentLeft;
			
		}
		
		void Bezier(ControlPoint[] controlPoints)
		{
 			for (int i =0; i<controlPoints.Length-1; i++)
			{
				var left = controlPoints[i];
				var right = controlPoints[i+1];
				Bezier(left.Position, left.TangentRight, right.TangentLeft, right.Position); 
			}
		}
		
		
		void Bezier(float2 p1, float2 p2, float2 p3, float2 p4)
	    {
			_verts.Clear();
	        AddPoint(p1.X, p1.Y);
	        RecursiveBezier(p1.X, p1.Y, p2.X, p2.Y, p3.X, p3.Y, p4.X, p4.Y);
	        AddPoint(p4.Y, p4.Y);
	    }
		
		void RecursiveBezier(float x1, float y1, 
		                      float x2, float y2, 
		                      float x3, float y3, 
		                      float x4, float y4)
		{
		    // Calculate all the mid-points of the line segments
		    var x12   = (x1 + x2) / 2;
		    var y12   = (y1 + y2) / 2;
		    var x23   = (x2 + x3) / 2;
		    var y23   = (y2 + y3) / 2;
		    var x34   = (x3 + x4) / 2;
		    var y34   = (y3 + y4) / 2;
		    var x123  = (x12 + x23) / 2;
		    var y123  = (y12 + y23) / 2;
		    var x234  = (x23 + x34) / 2;
		    var y234  = (y23 + y34) / 2;
		    var x1234 = (x123 + x234) / 2;
		    var y1234 = (y123 + y234) / 2;

			// Try to approximate the full cubic curve by a single straight line
			var dx = x4-x1;
			var dy = y4-y1;

			var d2 = Abs(((x2 - x4) * dy - (y2 - y4) * dx));
			var d3 = Abs(((x3 - x4) * dy - (y3 - y4) * dx));

			if((d2 + d3)*(d2 + d3) < 2.0f * (dx*dx + dy*dy))
			{
				AddPoint(x1234, y1234);
				return;
			}

			RecursiveBezier(x1, y1, x12, y12, x123, y123, x1234, y1234); 
	        RecursiveBezier(x1234, y1234, x234, y234, x34, y34, x4, y4); 
		}

		List<float2> _verts = new List<float2>();
		void AddPoint(float x, float y)
		{
			debug_log "add " + x + " " + y;
			_verts.Add(float2(x, y));
		}
		

		
		
        public override void Draw()
        {
			//_shape.Draw();
			float2[] _vertices;
			ushort[] _indices;

			/*var a = new List<float2>();
			var vertexCount = 1000;
			for (int v = 0, i = 0; v < vertexCount; v++)
			{
				var f = ((float)v / vertexCount) * Uno.Math.PIf*2;
				var b = (float)Math.Sin(FrameTime*2.0 + f*10.0f) * 0.2f + 1.0f;
				var p = float2(Math.Cos(f), Math.Sin(f));
				a.Add(p * b * 200.0f * Math.Max(0.3f,p.Y*2.0f));
			}*/

		var f = (float)Sin(FrameTime) ;
		var f2 = (float)Sin(FrameTime*1.9f);
		var f3 = (float)Sin(FrameTime*2.9f);

			Bezier(new ControlPoint[] { 
				new ControlPoint { Position = float2(0), TangentLeft = float2(0), TangentRight = float2(0) },
				new ControlPoint { Position = float2(100,100 + f*40.0f), TangentLeft = float2(100,80), TangentRight = float2(100,120) },
				new ControlPoint { Position = float2(200,50), TangentLeft = float2(250-f2*50.0f,100), TangentRight = float2(200,50) },
			});
			
		
			debug_log "yo";
			var result = new List<ushort>();
			Triangulate.Process(_verts, result);

			_vertices = _verts.ToArray();
			_indices = result.ToArray();

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