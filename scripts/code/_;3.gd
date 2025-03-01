extends GPUParticles3D

func _ready() -> void:
	SignalBus.connect("playProdParticles", playEffect)

func playEffect() -> void:
	emitting = true
