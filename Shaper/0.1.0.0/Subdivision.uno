using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Content;
using Uno.Content.Models;
using Uno.Math;

namespace Shaper
{
	class CurveSubdivision
	{
		public static IEnumerable<float2> CreatePolygon(IEnumerable<ControlPoint> controlPoints)
		{
			return new CurveSubdivision().Subdivide(controlPoints);
		}

		readonly List<float2> _result = new List<float2>();

		IEnumerable<float2> Subdivide(IEnumerable<ControlPoint> controlPointsn)
		{
			var controlPoints = EnumerableExtensions.ToArray(controlPointsn);

 			for (int i =0; i<controlPoints.Length-1; i++)
			{
				var left = controlPoints[i];
				var right = controlPoints[i+1];
				Subdivide(left.Position, left.TangentRight, right.TangentLeft, right.Position);
			}
			return _result;
		}

		void Subdivide(float2 p1, float2 p2, float2 p3, float2 p4)
	    {
	        //AddPoint(p1.X, p1.Y);
	        SubdivideRecursive(p1.X, p1.Y, p2.X, p2.Y, p3.X, p3.Y, p4.X, p4.Y);
	        //AddPoint(p4.Y, p4.Y);
	    }

		void SubdivideRecursive(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
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

			if((d2 + d3)*(d2 + d3) < 0.01f * (dx*dx + dy*dy))
			{
				AddPoint(x1234, y1234);
				return;
			}

			SubdivideRecursive(x1, y1, x12, y12, x123, y123, x1234, y1234);
	        SubdivideRecursive(x1234, y1234, x234, y234, x34, y34, x4, y4);
		}

		void AddPoint(float x, float y)
		{
			_result.Add(float2(x, y));
		}
	}
}
