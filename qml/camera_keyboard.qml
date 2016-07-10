import QtQuick 2.6 as QQ2

import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Input 2.0
import Qt3D.Logic 2.0
import Qt3D.Extras 2.0

import "Components"

Scene0 {
	id: scene

	Entity {
		id: root

		Camera {
			id: camera
			projectionType: CameraLens.PerspectiveProjection
			fieldOfView: 45  // Projection
			aspectRatio: scene.width/scene.height
			nearPlane : 0.1
			farPlane : 100.0
			position: Qt.vector3d(0,0,3) // View
			viewCenter: Qt.vector3d(0,0,0)
			upVector: Qt.vector3d(0,1,0)

			property vector3d frontNormalized: position.minus(viewCenter).normalized()
		}

		RenderSettings1 {
			camera: camera
		}

		InputSettings {
			id: inputSettings
			// isShareable: false  // Crash in App !!!
			//eventSource: scene // Auto, result by tests
		}

		KeyboardDevice { id: keyboard1 }

		KeyboardHandler {
			id: input
			sourceDevice: keyboard1
			focus: true // Required, by tests

			onPressed: {
				switch (event.key) {
					case Qt.Key_W: {
						movement.w = camera.frontNormalized
						break
					}
					case Qt.Key_S: {
						movement.s = camera.frontNormalized
						break
					}
					case Qt.Key_A: {
						movement.a = camera.frontNormalized.crossProduct(camera.upVector).normalized()
						break
					}
					case Qt.Key_D: {
						movement.d = camera.frontNormalized.crossProduct(camera.upVector).normalized()
						break
					}
					case Qt.Key_Shift: {
						movement.acc = .2
						break
					}
				}
			}

			onReleased: {
				switch (event.key) {
					case Qt.Key_W: {
						movement.w = movement.zero
						break
					}
					case Qt.Key_S: {
						movement.s = movement.zero
						break
					}
					case Qt.Key_A: {
						movement.a = movement.zero
						break
					}
					case Qt.Key_D: {
						movement.d = movement.zero
						break
					}
					case Qt.Key_Shift: {
						movement.acc = 1.
						break
					}
				}
			}
		}

		FrameAction {
			id: movement

			readonly property real scale: 1e1
			property real acc: 1.
			property vector3d w: Qt.vector3d(0,0,0)
			property vector3d s: Qt.vector3d(0,0,0)
			property vector3d a: Qt.vector3d(0,0,0)
			property vector3d d: Qt.vector3d(0,0,0)
			property vector3d velocity: w.minus(s).plus(a).minus(d)
			readonly property vector3d zero: Qt.vector3d(0,0,0)

			onTriggered: {
				if (velocity !== zero) {
					camera.translate(velocity.times(acc * scale * dt))
					console.log("camera.viewCenter = %1".arg(camera.viewCenter))
				}
			}
		}


		Transform {
			id: dummyTransform
		}

		property var cubePositions: [
			Qt.vector3d( 0.0,  0.0,  0.0),
			Qt.vector3d( 2.0,  5.0, -15.0),
			Qt.vector3d(-1.5, -2.2, -2.5),
			Qt.vector3d(-3.8, -2.0, -12.3),
			Qt.vector3d( 2.4, -0.4, -3.5),
			Qt.vector3d(-1.7,  3.0, -7.5),
			Qt.vector3d( 1.3, -2.0, -2.5),
			Qt.vector3d( 1.5,  2.0, -2.5),
			Qt.vector3d( 1.5,  0.2, -1.5),
			Qt.vector3d(-1.3,  1.0, -1.5)
		]

		QQ2.Component.onCompleted: {
			var component = Qt.createComponent("Components/Box0.qml")
			for (var i in cubePositions) {
				var box = component.createObject(root)
				box.index = i
				box.transform.translation = cubePositions[i]
				box.transform.rotation = Qt.binding(function(){
					return dummyTransform.fromAxisAndAngle(Qt.vector3d(1, .3, .5), root.angle * this.parent.index)
				})
			}
		}

		property real angle

		QQ2.NumberAnimation {
			target: root
			property: "angle"
			duration: 360*1000/20
			from: 0
			to: 360

			loops: QQ2.Animation.Infinite
			running: true
		}
	}

}
