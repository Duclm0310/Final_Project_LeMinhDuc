var exports = module.exports = {};

// --------------------------------------------------------------------------
// DataType definitions.  Used for validation and casting
var DataType = function(name,definition,validate,cast) {
	var self = this;
	self.name = name;
	self.definition = definition;
	self.validate = validate||function(val){return true;};
	self.cast = cast||function(val){return val;};
	exports[name] = function(description,required) {
		return new DataTypeClass(self,description,required);
	};
};

var DataTypeClass = function(datatype,description,required,defaultvalue) {
	var self = this;
	self.type = datatype.name;
	self.cast = datatype.cast;
	self.validate = datatype.validate;
	self.definition = datatype.definition;
	self.description = description||datatype.type;
	self.required = required?true:false;
	self.defaultvalue = defaultvalue||null;
	Object.defineProperty(self,"istype",{get:function(){return true;}});
};

// --------------------------------------------------------------------------
// Extended DataType creation method
//  params:
//    @datatype - the type object to create. Properties:
//              - "name"       - the name of the datatype           (required)
//				- "definition" - the textual definition             (optional)
//				- "validate"   - the validation function            (optional)
//				- "cast"       - the type casting function          (optional)
//				- "defaultvalue" - the default value to set         (optional)
var type = function(datatype) {
	
	var type_not_found = "ERROR - A datatype was not provided";
	if(!datatype) throw new Error(type_not_found);
	
	var type_name_not_valid = "ERROR - The datatype does not have a valid name";
	if(typeof datatype.name !== 'string') throw new Error(type_name_not_valid);
	
	var type_exists = "ERROR - The datatype '"+datatype.name+"' already exists";
	if(exports[datatype.name]) throw new Error(type_exists);
	
	var definition = (typeof datatype.definition === 'string') ? datatype.definition : datatype.name;
	var validate = (typeof datatype.validate === 'function') ? datatype.validate : function(){return true;};
	var cast = (typeof datatype.cast === 'function') ? datatype.cast : function(val){return val;};

	new DataType(datatype.name, definition, validate, cast);
	
};

// --------------------------------------------------------------------------
// Extended DataType creation method
//  params:
//    @datatypes - an array of type objects to create
var add = exports.add = function(datatypes) {

	var types_not_found = "ERROR - An array of datatypes was not provided";
	if (typeof datatypes !== 'object') throw new Error(types_not_found);

	if (datatypes instanceof Array) {
		datatypes.map(type);
	} else {
		type(datatypes);
	}

};

// --------------------------------------------------------------------------
// Verifies if an object is a datatype
//  params:
//    @object - The object to check
var isType = exports.isType = function(object) {
	return (object && object instanceof DataTypeClass) ? true : false;
};

// =============================================================================
// Declare default datatypes
add(require('./defaults').defaults);