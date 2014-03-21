using Uno;

namespace Shaper
{
	public abstract class Shape 
	{
		// Logic operators

		public Shape Union(Shape With)
		{
			throw new NotImplementedException();
		}

		public Shape Intersect(Shape With)
		{
			throw new NotImplementedException();
		}

		public Shape Subtract(Shape From)
		{
			throw new NotImplementedException();
		}

		// Fill

		public Shape Fill(Shape Shape)
		{
			throw new NotImplementedException();
		}

		public Shape Fill(Brush Brush)
		{
			throw new NotImplementedException();
		}

		public Shape Fill(texture2D Texture)
		{
			throw new NotImplementedException();
		}

		public Shape Fill(float4 Color)
		{
			throw new NotImplementedException();
		}

		// Outline

		public Shape Outline(float? Inner=null, float? Outer=null, Func<Shape,float> CalcInner=null, Func<Shape,float> CalcOuter=null)
		{
			return Clone();
		}

		public Shape Outline(float? Radius=null, Func<Shape,float> CalcRadius=null)
		{
			return Clone();
		}

		// Converting

		public abstract Shape Clone()
		{
			return new Circle();
		}

		public IEnumerable<Polygon> ToPolygons()
		{
			return new Polygon[];
		}
	}
}