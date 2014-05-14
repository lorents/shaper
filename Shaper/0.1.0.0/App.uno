using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Scenes.Primitives;
using Uno.Content;
using Uno.Content.Models;
using Uno.Math;
using Uno.Collections.EnumerableExtensions;

namespace Shaper
{
		class Line
	{
		static Line _instance = null;

		public static void Draw(float2 a, float2 b, float4 color)
		{
			(_instance ?? (_instance = new Line())).DrawLine(a,b,color);
		}

		void DrawLine(float2 a, float2 b, float4 color)
		{
			draw
			{
				float[] v: new [] { 0.0f, 1.0f };
				float vert : vertex_attrib(v);

				float2 p: a * (1-vert) + b * vert;

				ClipPosition : float4(((p-float2(0.5f))*Context.ResolutionMultiplier) / Context.Viewport.Size * float2(2.0f, -2.0f) - float2(1.0f, - 1.0f), 0, 1);
				PixelColor: color;

				PrimitiveType: Uno.Graphics.PrimitiveType.Lines;

				BlendEnabled: true;
				BlendSrc : Uno.Graphics.BlendOperand.SrcAlpha;
				BlendDst : Uno.Graphics.BlendOperand.OneMinusSrcAlpha;
			};
		}
	}
	class Handle
	{
		static Handle _instance = null;

		public static void Draw(float2 position, float radius)
		{
			(_instance ?? (_instance = new Handle())).DrawInternal(position,radius / Context.ResolutionMultiplier);
		}

		void DrawInternal(float2 position, float radius)
		{
			draw Uno.Scenes.Primitives.Quad
			{

				float2 vPos : position - vSize / 2.0f;
				float2 vSize : float2(radius*2.0f);

				Position : float3((vPos) / Context.Viewport.Size * 2.0f - 1.0f, -1);
				Size : vSize * Context.ResolutionMultiplier / Context.Viewport.Size * 2.0f;

				ClipPosition : prev * float4(1,-1,1,1);

				DepthTestEnabled : false;
				CullFace : Uno.Graphics.PolygonFace.None;
				float e : Vector.Length(pixel (VertexData * 2 - 1));
				PixelColor : float4(1.0f,1.0f,1.0f,1.0f - Math.SmoothStep(0.9f, 1.1f,e));
				BlendEnabled: true;
				BlendSrc : Uno.Graphics.BlendOperand.SrcAlpha;
				BlendDst : Uno.Graphics.BlendOperand.OneMinusSrcAlpha;

				drawable block Outline
				{
					vSize: prev+2f;
					PixelColor: prev * float4(0.2f,0.2f,0.2f,1);
				}

				float grad: 0.8f;

				drawable block Fill
				{
					PixelColor: prev * float4(grad, grad,1,1);
				}


			};
		}
	}
}
