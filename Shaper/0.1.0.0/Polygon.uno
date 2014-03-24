using Uno.Collections;

namespace Shaper
{
	class ControlPoint
	{
		public float2 Position;
		public float2 TangentRight;
		public float2 TangentLeft;
	}
		
	public class Polygon
	{
		public IEnumerable<ConvexPolygon> ToConvexPolygons()
		{
			return new List<ConvexPolygon>();
		}
	}
}