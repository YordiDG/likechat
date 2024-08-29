
/*import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'dart:io' show Platform;

class FaceFiltersScreen extends StatefulWidget {
  @override
  _FaceFiltersScreenState createState() => _FaceFiltersScreenState();
}

class _FaceFiltersScreenState extends State<FaceFiltersScreen> {
  ARKitController? arkitController;
  ArCoreController? arcoreController;
  int currentFilter = 0;

  @override
  void dispose() {
    arkitController?.dispose();
    arcoreController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Face Filters'),
      ),
      body: Stack(
        children: [
          if (Platform.isIOS)
            ARKitSceneView(
              onARKitViewCreated: onARKitViewCreated,
              configuration: ARKitConfiguration.faceTracking,
            )
          else if (Platform.isAndroid)
            ArCoreView(
              onArCoreViewCreated: onArCoreViewCreated,
              enableTapRecognizer: true,
              type: ArCoreViewType.AUGMENTEDFACE,
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.face),
                    onPressed: () => setFilter(0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.face),
                    onPressed: () => setFilter(1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.face),
                    onPressed: () => setFilter(2),
                  ),
                  IconButton(
                    icon: const Icon(Icons.face),
                    onPressed: () => setFilter(3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    arkitController?.onAddNodeForAnchor = _handleAddNodeForAnchor;
  }

  void onArCoreViewCreated(ArCoreController controller) {
    arcoreController = controller;
    arcoreController?.onPlaneTap = _handlePlaneTap;
  }

  void _handleAddNodeForAnchor(ARKitAnchor anchor) {
    if (anchor is ARKitFaceAnchor) {
      switch (currentFilter) {
        case 0:
          _applyFilter1(anchor);
          break;
        case 1:
          _applyFilter2(anchor);
          break;
        case 2:
          _applyFilter3(anchor);
          break;
        case 3:
          _applyFilter4(anchor);
          break;
      }
    }
  }

  void _handlePlaneTap(List<ArCoreHitTestResult> results) {
    if (currentFilter >= 0 && currentFilter <= 3) {
      for (var result in results) {
        _applyFilterForArCore(result);
      }
    }
  }

  void _applyFilter1(dynamic anchor) {
    final node = ARKitNode(
      geometry: ARKitBox(
        materials: [ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.blue))],
        width: 0.2,
        height: 0.2,
        length: 0.2,
      ),
      position: anchor.transform.getColumn(3).xyz,
    );
    arkitController?.add(node);
  }

  void _applyFilter2(dynamic anchor) {
    final node = ARKitNode(
      geometry: ARKitBox(
        materials: [ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.green))],
        width: 0.2,
        height: 0.2,
        length: 0.2,
      ),
      position: anchor.transform.getColumn(3).xyz,
    );
    arkitController?.add(node);
  }

  void _applyFilter3(dynamic anchor) {
    final node = ARKitNode(
      geometry: ARKitBox(
        materials: [ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.yellow))],
        width: 0.2,
        height: 0.2,
        length: 0.2,
      ),
      position: anchor.transform.getColumn(3).xyz,
    );
    arkitController?.add(node);
  }

  void _applyFilter4(dynamic anchor) {
    final node = ARKitNode(
      geometry: ARKitBox(
        materials: [ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.red))],
        width: 0.2,
        height: 0.2,
        length: 0.2,
      ),
      position: anchor.transform.getColumn(3).xyz,
    );
    arkitController?.add(node);
  }

  void _applyFilterForArCore(ArCoreHitTestResult result) {
    final node = ArCoreNode(
      shape: ArCoreSphere(
        materials: [ArCoreMaterial(color: Colors.blue)],
        radius: 0.02,
      ),
      position: result.pose.translation,
    );
    arcoreController?.addArCoreNode(node);
  }

  void setFilter(int filterIndex) {
    setState(() {
      currentFilter = filterIndex;
    });
  }
}
*/