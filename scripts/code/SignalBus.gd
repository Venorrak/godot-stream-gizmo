extends Node
class_name signalBus

signal websocketMessage
signal createPopup # content, title, position
signal animationChange #name
signal faceColorChanged #color
signal createJoel #size(optional), image(optional)
signal EmoteJoelsEnabled #bool
signal createOverlayElement #object, position(on screen)
signal clearOverlayElements
signal OverlayElementsEnabled #bool
signal createNewMessageListComponent
signal sendMessageToBus #Dict
