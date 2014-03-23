using Uno;
using Uno.Collections;

namespace Shaper
{
	public abstract class Shape
	{
		// Logic operators

		public Shape Union(Shape With)
		{
			return new Union(this, With);
		}

		public Shape Intersect(Shape With)
		{
			return new Intersect(this, With);
		}

		public Shape Inverse()
		{
			return new Inverse(this);
		}

		public Shape Subtract(Shape From)
		{
			return new Subtract(this, From);
		}

		// Fill

		//public Shape Fill(Shape Shape)
		//{
		//	throw new NotImplementedException();
		//}

		//public Shape Fill(Brush Brush)
		//{
		//	throw new NotImplementedException();
		//}

		//public Shape Fill(texture2D Texture)
		//{
		//	throw new NotImplementedException();
		//}

		//public Shape Fill(float4 Color)
		//{
		//	return new Fill(this, Color);
		//}

		// Outline

		public Shape Shrink(float Amount)
		{
			throw new NotImplementedException();
		}

		public Shape Expand(float Amount)
		{
			throw new NotImplementedException();
		}

		public Shape Outline(float Radius)
		{
			var halfRadius = Radius / 2.0f;
			return Expand(halfRadius).Subtract(Shrink(halfRadius));
		}

		//public Shape Outline(float? Inner=null, float? Outer=null, Func<Shape,float> CalcInner=null, Func<Shape,float> CalcOuter=null)
		//{
		//	return Clone();
		//}

		//public Shape Outline(float? Radius=null, Func<Shape,float> CalcRadius=null)
		//{
		//	return Clone();
		//}

		// Converting


		//public IEnumerable<Polygon> ToPolygons()
		//{
		//	return new List<Polygon>();
		//}

		internal abstract void Draw(DrawContext dc);

		public virtual void Draw()
		{
			Draw(new DrawContext());
		}
	}

	class DrawContext
	{

	}
}