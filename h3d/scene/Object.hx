package h3d.scene;

class Object {

	static inline var ROT2RAD = -0.017453292519943295769236907684886;
	
	var childs : Array<Object>;
	public var parent(default,null) : Object;
	
	public var name : Null<String>;
	public var x(default,set) : Float;
	public var y(default, set) : Float;
	public var z(default, set) : Float;
	public var scaleX(default,set) : Float;
	public var scaleY(default, set) : Float;
	public var scaleZ(default,set) : Float;

	public var defaultTransform(default,set) : h3d.Matrix;
	var absPos : h3d.Matrix;
	var qRot : h3d.Quat;
	var posChanged : Bool;
	
	public function new( ?parent : Object ) {
		absPos = new h3d.Matrix();
		absPos.identity();
		x = 0; y = 0; z = 0; scaleX = 1; scaleY = 1; scaleZ = 0;
		qRot = new h3d.Quat();
		posChanged = false;
		childs = [];
		if( parent != null )
			parent.addChild(this);
	}
	
	public function getObjectByName( name : String ) {
		if( this.name == name )
			return this;
		for( c in childs ) {
			var o = c.getObjectByName(name);
			if( o != null ) return o;
		}
		return null;
	}
	
	public function getObjectsCount() {
		var k = 0;
		for( c in childs )
			k += c.getObjectsCount() + 1;
		return k;
	}
	
	public function addChild( o : Object ) {
		addChildAt(o, childs.length);
	}
	
	public function addChildAt( o : Object, pos : Int ) {
		if( pos < 0 ) pos = 0;
		if( pos > childs.length ) pos = childs.length;
		var p = this;
		while( p != null ) {
			if( p == o ) throw "Recursive addChild";
			p = p.parent;
		}
		if( o.parent != null )
			o.parent.removeChild(o);
		childs.insert(pos,o);
		o.parent = this;
		o.posChanged = true;
	}
	
	public function removeChild( o : Object ) {
		if( childs.remove(o) )
			o.parent = null;
	}
	
	public inline function isMesh() {
		return Std.is(this, Mesh);
	}
	
	public function toMesh() : Mesh {
		if( isMesh() )
			return cast this;
		throw (name == null ? "Object" : name) + " is not a Mesh";
	}
	
	// shortcut for parent.removeChild
	public inline function remove() {
		if( this != null && parent != null ) parent.removeChild(this);
	}
	
	function draw( ctx : RenderContext ) {
	}
	
	function updatePos() {
		if( parent != null && parent.posChanged )
			posChanged = true;
		if( posChanged ) {
			qRot.saveToMatrix(absPos);
			// prepend scale
			absPos._11 *= scaleX;
			absPos._12 *= scaleX;
			absPos._13 *= scaleX;
			absPos._21 *= scaleY;
			absPos._22 *= scaleY;
			absPos._23 *= scaleY;
			absPos._31 *= scaleY;
			absPos._32 *= scaleY;
			absPos._33 *= scaleY;
			absPos._41 = x;
			absPos._42 = y;
			absPos._43 = z;
			if( defaultTransform != null )
				absPos.multiply3x4(absPos, defaultTransform);
			if( parent != null )
				absPos.multiply3x4(absPos, parent.absPos);
		}
	}
	
	function renderContext( ctx : RenderContext ) {
		updatePos();
		draw(ctx);
		for( c in childs )
			c.renderContext(ctx);
		posChanged = false;
	}
	
	inline function set_x(v) {
		x = v;
		posChanged = true;
		return v;
	}

	inline function set_y(v) {
		y = v;
		posChanged = true;
		return v;
	}

	inline function set_z(v) {
		z = v;
		posChanged = true;
		return v;
	}
	
	inline function set_scaleX(v) {
		scaleX = v;
		posChanged = true;
		return v;
	}
	
	inline function set_scaleY(v) {
		scaleY = v;
		posChanged = true;
		return v;
	}

	inline function set_scaleZ(v) {
		scaleZ = v;
		posChanged = true;
		return v;
	}
	
	inline function set_defaultTransform(v) {
		defaultTransform = v;
		posChanged = true;
		return v;
	}
	
	/*
		Move along the current rotation axis
	*/
	public function move( dx : Float, dy : Float, dz : Float ) {
		throw "TODO";
	}

	public inline function setPos( x : Float, y : Float, z : Float ) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	/*
		Rotate around the current rotation axis.
	*/
	public function rotate( rx : Float, ry : Float, rz : Float ) {
		throw "TODO";
	}
	
	public function setRotate( rx : Float, ry : Float, rz : Float ) {
		qRot.initRotate(rx, ry, rz);
		posChanged = true;
	}
	
	public function setRotateAxis( ax : Float, ay : Float, az : Float, angle : Float ) {
		qRot.initRotateAxis(ax, ay, az, angle);
		posChanged = true;
	}
	
	public inline function scale( v : Float ) {
		scaleX *= v;
		scaleY *= v;
		scaleZ *= v;
	}
	
	public inline function setScale( v : Float ) {
		scaleX = v;
		scaleY = v;
		scaleZ = v;
	}
	
	public function toString() {
		return Type.getClassName(Type.getClass(this)).split(".").pop() + (name == null ? "" : "(" + name + ")");
	}
	
}
