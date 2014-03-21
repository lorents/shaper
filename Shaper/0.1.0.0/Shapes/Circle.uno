
namespace Shaper
{
	public class Circle : Shape
	{
		public float Radius { get; private set; }
		public float2 Position { get; private set; }
		
		public Circle(float Radius = 10.0f, float2 Position = float2(0)/*, Func<Shape, float> CalcRadius = null, Func<Shape, float2> CalcPosition = null*/)
		{
			this.Radius = Radius;
			this.Position = Position;
		}
		
		internal override void DrawAt(float2 origin, int z)
		{
		}
	}
}