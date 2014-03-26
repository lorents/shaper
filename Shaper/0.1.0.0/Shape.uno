using Uno;
using Uno.Collections;

namespace Shaper
{
	public class Tweener
	{
		readonly double _time;
		
		public Tweener(double time) 
		{ 
			_time = time; 
		}
		
		public float Sin(float Frequency = 1.0f, float Phase = 0.0f) { return (float)Math.Sin(_time * Frequency + Phase); }
		public float Cos(float Frequency = 1.0f, float Phase = 0.0f) { return (float)Math.Cos(_time * Frequency + Phase); }

		public float2 EaseIn(float2 From, float2 To, double At=0.0, double Duration=0.2, float Amount = 1.0f) 
		{
			return From + (To - From) * (float)Math.Saturate((_time - At) / Duration);
		}
		
		public float2 EaseOut(float2 From, float2 To, double At=0.0, double Duration=0.2, float Amount = 1.0f) 
		{ 
			return From + (To - From) * (float)Math.Saturate((_time - At) / Duration);
		}
	}

	//.Animate(Position: t => t.EaseIn(float2(10,0), float2(10,10)));

	public abstract class Shape
	{
		public float2 Position { get; private set; }
		public Func<Tweener, float2> EvalPosition { get; private set; }
		
		public float2 Scaling { get; private set; }
		public Func<Tweener, float2> EvalScaling { get; private set; }

		public double TimeOffset { get; private set; }
		
		protected Shape(
			double TimeOffset = 0,
			float2 Position = float2(0), Func<Tweener, float2> EvalPosition = null,
			float2 Scale = float2(1), Func<Tweener, float2> EvalScale = null)
		{
			this.TimeOffset = TimeOffset;
			this.Position = Position;
			this.EvalPosition = EvalPosition;
			this.Scaling = Scale;
			this.EvalScaling = EvalScale;
		}
		
		// Animate

		//public Shape Animate(Func<Tweener, float2> Position = null)
		//{
		//	EvalPosition = Position;
		//}

		public virtual Shape Delay(double time)
		{
			return this;
		}

		// Logic operators

		public Shape Union(Shape With)
		{
			return new Union(this, With);
		}

		public static Shape operator+ (Shape what, Shape with)
		{
			return what.Union(with);
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

		// Transform

		public virtual Shape Translate(float2 offset)
		{
			return this;
		}

		public Shape Scale(float2 scale, float2 pivot = float2(0))
		{
			return this;
		}

		public Shape Rotate(float degrees, float2 pivot = float2(0))
		{
			return this;
		}

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

		// Converting


		//public IEnumerable<Polygon> ToPolygons()
		//{
		//	return new List<Polygon>();
		//}

		internal abstract void Draw(DrawContext dc, double time);

		public virtual void Draw()
		{
			Draw(new DrawContext(), Uno.Application.Current.FrameTime);
		}

	}

	class DrawContext
	{

	}
}