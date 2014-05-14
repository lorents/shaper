using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Scenes;
using Uno.Content;
using Uno.Content.Models;
using Uno.Designer;
using Uno.Collections.EnumerableExtensions;
using Uno.UI;

namespace Shaper
{
	[Tool, Priority(10)]
	public class CreatePath : ToolStateMachine<CreatePath>
	{
		internal DesignerModelChange Connection { get; set; }

		public CreatePath() : base (new NotCreatedPath()) { }
	}

	class NotCreatedPath : ToolState<CreatePath>
	{
		public override ToolState<CreatePath> OnPointerDown(PointerDownArgs a)
		{
			a.IsHandled = true;
			var path = new Path();
			Tool.Connection = Tool.Designer.ConnectToDefaultConnector(path);
			var pos = path.FromAbsolute(a.PointCoord);
			path.ControlPoints.Clear();
			path.ControlPoints.Add(new ControlPoint() { Position = pos, TangentLeft = pos, TangentRight = pos });
			return new CreatingPath(path);
		}
	}

	class CreatingPath : ToolState<CreatePath>
	{
		readonly Path _path;

		public CreatingPath(Path path)
		{
			_path = path;
		}

		public override ToolState<CreatePath> OnPointerDown(PointerDownArgs a)
		{
			a.IsHandled = true;
			var pos = _path.FromAbsolute(a.PointCoord);

			var len =Vector.Length(pos - _path.ControlPoints[0].Position) ;
			if (len < 10)
			{
				Tool.Designer.Model.Record(
					Tool.Connection,
					new NodeAdded(_path),
					new PropertyChanged(_path, "Data"), 
					new Select(_path));
				
				return new NotCreatedPath();
			}
			
			_path.ControlPoints.Add(new ControlPoint() { Position = pos, TangentLeft = pos, TangentRight = pos });
			return this;
		}

		public override void OnDraw()
		{
			foreach (var point in _path.ControlPoints)
				Handle.Draw(_path.ToAbsolute(point.Position), 3.0f);
			_path.DrawOutline(_path.ActualPosition);
		}
	}

	[Tool, Priority(-2)]
	public class PathGizmo : ToolStateMachine<PathGizmo>
	{
		public Path Path
		{
			get { return FirstOrDefault(Designer.Selection.Items) as Path; }
		}

		public int ControlPointIndex { get; set; }

		public ControlPoint ControlPoint
		{
			get { return Path == null ||  ControlPointIndex < 0 || ControlPointIndex >= Path.ControlPoints.Count ? null : Path.ControlPoints[ControlPointIndex]; }
		}

		public PathGizmo()
			: base(new Idle())
		{
		}

		protected override void OnDraw()
		{
			DrawOutline();
			DrawTangents();
			DrawPoints();
			base.OnDraw();
		}

		void DrawOutline()
		{
			if (Path == null) return;
			Path.DrawOutline(Path.ActualPosition);
		}

		void DrawPoints()
		{
			if (Path == null) return;
			foreach (var point in Path.ControlPoints)
			{
				var p = Path.ToAbsolute(point.Position);
				Handle.Draw(p, 3.0f);
			}
		}

		void DrawTangents()
		{
			if (ControlPoint == null) return;
			var p = Path.ToAbsolute(ControlPoint.Position);
			var tl = Path.ToAbsolute(ControlPoint.TangentLeft);
			var tr = Path.ToAbsolute(ControlPoint.TangentRight);
			Line.Draw(p, tl, float4(1,1,1,0.8f));
			Line.Draw(p, tr, float4(1,1,1,0.8f));
			Handle.Draw(tl, 3.0f);
			Handle.Draw(tr, 3.0f);
		}

	}

	class Idle : ToolState<PathGizmo>
	{
		public override ToolState<PathGizmo> OnPointerDown(PointerDownArgs a)
		{
			if (Tool.Path == null) return this;

			if (a.IsHandled) return this;
			a.IsHandled = true;

			var p = Tool.Path.FromAbsolute(a.PointCoord);
			a.CapturePointer();

			for (int i=0; i<Tool.Path.ControlPoints.Count; i++)
			{
				var point = Tool.Path.ControlPoints[i];
				if (Vector.Length(point.Position - p) < 10.0f)
				{
					Tool.ControlPointIndex = i;
					if (!a.IsPrimary)
						return new MovingRight(point);
					return new MovingPoint(point);
				}
			}

			var selectedPoint = Tool.ControlPoint;
			if (selectedPoint != null)
			{
				if (Vector.Length(selectedPoint.TangentLeft - p) < 10.0f)
					return new MovingLeft(selectedPoint);
				if (Vector.Length(selectedPoint.TangentRight - p) < 10.0f)
					return new MovingRight(selectedPoint);
			}

			Tool.ControlPointIndex = -1;
			a.IsHandled = false;
			a.ReleasePointer();
			return this;
		}
	}

	class MovingPoint : ToolState<PathGizmo>
	{
		public ControlPoint _point;

		public MovingPoint(ControlPoint point)
		{
			_point = point;
		}

		public override ToolState<PathGizmo> OnPointerMove(PointerMoveArgs a)
		{
			var p = Tool.Path.FromAbsolute(a.PointCoord);
			var delta = p - _point.Position;
			_point.Position += delta;
			_point.TangentLeft += delta;
			_point.TangentRight += delta;
			return this;
		}

		public override ToolState<PathGizmo> OnPointerUp(PointerUpArgs a)
		{
			Tool.Designer.Model.RecordPropertyChanged(Tool.Path, "Data");
			a.ReleasePointer();
			return new Idle();
		}
	}

	class MovingLeft : ToolState<PathGizmo>
	{
		public ControlPoint _point;

		public MovingLeft(ControlPoint point)
		{
			_point = point;
		}

		public override ToolState<PathGizmo> OnPointerMove(PointerMoveArgs a)
		{
			var p = Tool.Path.FromAbsolute(a.PointCoord);
			var delta = p - _point.TangentLeft;
			_point.TangentLeft += delta;
			_point.TangentRight = _point.Position + (_point.Position - _point.TangentLeft);
			return this;
		}

		public override ToolState<PathGizmo> OnPointerUp(PointerUpArgs a)
		{
			Tool.Designer.Model.RecordPropertyChanged(Tool.Path, "Data");
			a.ReleasePointer();
			return new Idle();
		}
	}

	class MovingRight : ToolState<PathGizmo>
	{
		public ControlPoint _point;

		public MovingRight(ControlPoint point)
		{
			_point = point;
		}

		public override ToolState<PathGizmo> OnPointerMove(PointerMoveArgs a)
		{
			var p = Tool.Path.FromAbsolute(a.PointCoord);
			var delta = p - _point.TangentRight;
			_point.TangentRight += delta;
			_point.TangentLeft = _point.Position + (_point.Position - _point.TangentRight);
			return this;
		}

		public override ToolState<PathGizmo> OnPointerUp(PointerUpArgs a)
		{
			Tool.Designer.Model.RecordPropertyChanged(Tool.Path, "Data");
			a.ReleasePointer();
			return new Idle();
		}
	}
}