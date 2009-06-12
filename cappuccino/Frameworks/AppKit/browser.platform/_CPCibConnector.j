I;21;Foundation/CPObject.jI;29;Foundation/CPKeyValueCoding.jc;3305;
var _1="_CPCibConnectorSourceKey",_2="_CPCibConnectorDestinationKey",_3="_CPCibConnectorLabelKey";
var _4=objj_allocateClassPair(CPObject,"_CPCibConnector"),_5=_4.isa;
class_addIvars(_4,[new objj_ivar("_source"),new objj_ivar("_destination"),new objj_ivar("_label")]);
objj_registerClassPair(_4);
objj_addClassForBundle(_4,objj_getBundleWithPath(OBJJ_CURRENT_BUNDLE.path));
class_addMethods(_4,[new objj_method(sel_getUid("replaceObjects:"),function(_6,_7,_8){
with(_6){
var _9=_8[objj_msgSend(_source,"hash")];
if(_9!==undefined){
_source=_9;
}
_9=_8[objj_msgSend(_destination,"hash")];
if(_9!==undefined){
_destination=_9;
}
}
}),new objj_method(sel_getUid("x"),function(_a,_b){
with(_a){
if(replacements[objj_msgSend(_source,"hash")]){
_source=replacements[objj_msgSend(_source,"hash")];
}
if(replacements[objj_msgSend(_destination,"hash")]){
_destination=replacements[objj_msgSend(_destination,"hash")];
}
}
})]);
var _4=objj_getClass("_CPCibConnector");
if(!_4){
objj_exception_throw(new objj_exception(OBJJClassNotFoundException,"*** Could not find definition for class \"_CPCibConnector\""));
}
var _5=_4.isa;
class_addMethods(_4,[new objj_method(sel_getUid("initWithCoder:"),function(_c,_d,_e){
with(_c){
_c=objj_msgSendSuper({receiver:_c,super_class:objj_getClass("CPObject")},"init");
if(_c){
_source=objj_msgSend(_e,"decodeObjectForKey:",_1);
_destination=objj_msgSend(_e,"decodeObjectForKey:",_2);
_label=objj_msgSend(_e,"decodeObjectForKey:",_3);
}
return _c;
}
}),new objj_method(sel_getUid("encodeWithCoder:"),function(_f,_10,_11){
with(_f){
objj_msgSend(_11,"encodeObject:forKey:",_source,_1);
objj_msgSend(_11,"encodeObject:forKey:",_destination,_2);
objj_msgSend(_11,"encodeObject:forKey:",_label,_3);
}
})]);
var _4=objj_allocateClassPair(_CPCibConnector,"_CPCibControlConnector"),_5=_4.isa;
objj_registerClassPair(_4);
objj_addClassForBundle(_4,objj_getBundleWithPath(OBJJ_CURRENT_BUNDLE.path));
class_addMethods(_4,[new objj_method(sel_getUid("establishConnection"),function(_12,_13){
with(_12){
var _14=_label;
if(!objj_msgSend(_14,"hasSuffix:",":")){
_14+=":";
}
var _15=CPSelectorFromString(_14);
if(!_15){
objj_msgSend(CPException,"raise:reason:",CPInvalidArgumentException,"-["+objj_msgSend(_12,"className")+" "+_13+"] selector "+_14+" does not exist.");
}
if(objj_msgSend(_source,"respondsToSelector:",sel_getUid("setAction:"))){
objj_msgSend(_source,sel_getUid("setAction:"),_15);
}else{
objj_msgSend(CPException,"raise:reason:",CPInvalidArgumentException,"-["+objj_msgSend(_12,"className")+" "+_13+"] "+objj_msgSend(_source,"description")+" does not respond to setAction:");
}
if(objj_msgSend(_source,"respondsToSelector:",sel_getUid("setTarget:"))){
objj_msgSend(_source,sel_getUid("setTarget:"),_destination);
}else{
objj_msgSend(CPException,"raise:reason:",CPInvalidArgumentException,"-["+objj_msgSend(_12,"className")+" "+_13+"] "+objj_msgSend(_source,"description")+" does not respond to setTarget:");
}
}
})]);
var _4=objj_allocateClassPair(_CPCibConnector,"_CPCibOutletConnector"),_5=_4.isa;
objj_registerClassPair(_4);
objj_addClassForBundle(_4,objj_getBundleWithPath(OBJJ_CURRENT_BUNDLE.path));
class_addMethods(_4,[new objj_method(sel_getUid("establishConnection"),function(_16,_17){
with(_16){
objj_msgSend(_source,"setValue:forKey:",_destination,_label);
}
})]);
