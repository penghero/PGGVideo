//
//  PGG_ARViewController.m
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/16.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import "PGG_ARViewController.h"
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>

@interface PGG_ARViewController ()<ARSCNViewDelegate,ARSessionDelegate>
 /*AR视图：展示3D界面*/
@property (nonatomic, strong)ARSCNView *arSCNView;
/*AR会话，负责管理相机追踪配置及3D相机坐标*/
@property(nonatomic,strong)ARSession *arSession;
 /*会话追踪配置*/
@property(nonatomic,strong)ARWorldTrackingConfiguration *arSessionConfiguration;
/* Node对象 */
@property(nonatomic, strong) SCNNode *sunNode;//太阳
@property(nonatomic, strong) SCNNode *earthNode;//地球
@property(nonatomic, strong) SCNNode *moonNode;//月球
@property(nonatomic, strong) SCNNode *marsNode; //火星
@property(nonatomic, strong) SCNNode *mercuryNode;//水星
@property(nonatomic, strong) SCNNode *venusNode;//金星
@property(nonatomic, strong) SCNNode *jupiterNode; //木星
@property(nonatomic, strong) SCNNode *jupiterLoopNode; //木星环
@property(nonatomic, strong) SCNNode *jupiterGroupNode;//木星环
@property(nonatomic, strong) SCNNode *saturnNode; //土星
@property(nonatomic, strong) SCNNode *saturnLoopNode; //土星环
@property(nonatomic, strong) SCNNode *sartunGruopNode;//土星Group
@property(nonatomic, strong) SCNNode *uranusNode; //天王星
@property(nonatomic, strong) SCNNode *uranusLoopNode; //天王星环
@property(nonatomic, strong) SCNNode *uranusGroupNode; //天王星Group
@property(nonatomic, strong) SCNNode *neptuneNode; //海王星
@property(nonatomic, strong) SCNNode *neptuneLoopNode; //海王星环
@property(nonatomic, strong) SCNNode *neptuneGroupNode; //海王星Group
@property(nonatomic, strong) SCNNode *plutoNode; //冥王星
@property(nonatomic, strong) SCNNode *earthGroupNode;
@property(nonatomic, strong) SCNNode *sunHaloNode;
@property(nonatomic,strong)  AVPlayer *audioPlayer;

@end

@implementation PGG_ARViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
    
    [self.view addSubview:self.arSCNView];
//        开启AR会话，相机开始捕捉
    [self.arSession runWithConfiguration:self.arSessionConfiguration];
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -ARSessionDelegate
    //会话位置更新
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame
{
        //监听手机的移动，实现近距离查看太阳系细节，为了凸显效果变化值*3
    [_sunNode setPosition:SCNVector3Make(-3 * frame.camera.transform.columns[3].x, -0.1 - 3 * frame.camera.transform.columns[3].y, -2 - 3 * frame.camera.transform.columns[3].z)];
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"找到了新的平面");
}
#pragma mark - 初始化ARSCNView 用来加载AR的3D场景视图
- (ARSCNView *)arSCNView {
    if (!_arSCNView ) {
        _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
//绑定session
        _arSCNView.session = self.arSession;
//自适应环境光照度，过渡更平滑
        _arSCNView.automaticallyUpdatesLighting = YES;
        _arSCNView.delegate = self;
//初始化节点
        [self initNodeWithRootView:_arSCNView];
    }
    return _arSCNView;
}
#pragma mark - ARSessionConfiguration(会话追踪配置)主要目的就是负责追踪相机在3D世界中的位置以及一些特征场景的捕捉，需要配置一些参数
- (ARWorldTrackingConfiguration *)arSessionConfiguration {
    if (!_arSessionConfiguration) {
        //1.创建世界追踪会话配置（使用ARWorldTrackingSessionConfiguration效果更加好），需要A9芯片支持
        ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
        //2.设置追踪方向（追踪平面，后面会用到）
        configuration.planeDetection = ARPlaneDetectionHorizontal;
        _arSessionConfiguration = configuration;
        //3.自适应灯光（相机从暗到强光快速过渡效果会平缓一些）
        _arSessionConfiguration.lightEstimationEnabled = YES;
    }
    return _arSessionConfiguration;
}
#pragma mark - ARSession通过管理ARSessionConfiguration实现场景的追踪并且返回一个ARFrame
- (ARSession *)arSession {
    if(!_arSession){
        _arSession = [[ARSession alloc] init];
        _arSession.delegate = self;
    }
    return _arSession;
}

-(void)mathRoation{
        // 相关数学知识点： 任意点a(x,y)，绕一个坐标点b(rx0,ry0)逆时针旋转a角度后的新的坐标设为c(x0, y0)，有公式：
        //    x0= (x - rx0)*cos(a) - (y - ry0)*sin(a) + rx0 ;
        //
        //    y0= (x - rx0)*sin(a) + (y - ry0)*cos(a) + ry0 ;
        // custom Action
    float totalDuration = 10.0f;        //10s 围绕地球转一圈
    float duration = totalDuration/360;  //每隔duration秒去执行一次
    SCNAction *customAction = [SCNAction customActionWithDuration:duration actionBlock:^(SCNNode * _Nonnull node, CGFloat elapsedTime){
        if(elapsedTime == duration){
            SCNVector3 position = node.position;
            float rx0 = 0;    //原点为0
            float ry0 = 0;
            float angle = 1.0f/180*M_PI;
            float x =  (position.x - rx0)*cos(angle) - (position.z - ry0)*sin(angle) + rx0 ;
            float z = (position.x - rx0)*sin(angle) + (position.z - ry0)*cos(angle) + ry0 ;
            node.position = SCNVector3Make(x, node.position.y, z);
        }
    }];
    SCNAction *repeatAction = [SCNAction repeatActionForever:customAction];
    [_earthGroupNode runAction:repeatAction];
}
#pragma mark - 节点初始化
/*
 * SceneNode
 SceneNode提供几种几何模型，例如六面体(SCNBox)、平面(SCNPlane，只有一面)、无限平面(SCNFloor，沿着x-z平面无限延伸)、球体(SCNSphere)
 
 * SCNMaterial
 SceneNode提供8种属性用来设置模型材质
 Diffuse 漫发射属性表示光和颜色在各个方向上的反射量
 Ambient 环境光以固定的强度和固定的颜色从表面上的所有点反射出来。如果场景中没有环境光对象，这个属性对节点没有影响
 Specular 镜面反射是直接反射到使用者身上的光线，类似于镜子反射光线的方式。此属性默认为黑色，这将导致材料显得呆滞
 Normal 正常照明是一种用于制造材料表面光反射的技术，基本上，它试图找出材料的颠簸和凹痕，以提供更现实发光效果
 Reflective 反射光属性是一个镜像表面反射环境。表面不会真实地反映场景中的其他物体
 Emission 该属性是由模型表面发出的颜色。默认情况下，此属性设置为黑色。如果你提供了一个颜色，这个颜色就会体现出来，你可以提供一个图像。SceneKit将使用此图像提供“基于材料的发光效应”。
 Transparent 用来设置材质的透明度
 Multiply 通过计算其他所有属性的因素生成最终的合成的颜色
 
 *3. SCNLight
 SceneNode中完全都是动态光照，提供四种类型的光照
 SCNLightTypeAmbient 环境光
 SCNLightTypeOmni 聚光灯
 SCNLightTypeDirectional 定向光源
 SCNLightTypeSpot 点光源
 
 */
- (void)initNodeWithRootView:(SCNView *) scnView{
    _sunNode = [SCNNode new];
    _mercuryNode = [SCNNode new];
    _venusNode = [SCNNode new];
    _earthNode = [SCNNode new];
    _moonNode = [SCNNode new];
    _marsNode = [SCNNode new];
    _earthGroupNode = [SCNNode new];
    _jupiterNode = [SCNNode new];
    _saturnNode = [SCNNode new];
    _saturnLoopNode = [SCNNode new];
    _sartunGruopNode = [SCNNode new];
    _uranusNode = [SCNNode new];
    _neptuneNode = [SCNNode new];
    _plutoNode = [SCNNode new];
//    创建半径球体
    _sunNode.geometry = [SCNSphere sphereWithRadius:0.25];
    _mercuryNode.geometry = [SCNSphere sphereWithRadius:0.02];
    _venusNode.geometry = [SCNSphere sphereWithRadius:0.04];
    _marsNode.geometry = [SCNSphere sphereWithRadius:0.03];
    _earthNode.geometry = [SCNSphere sphereWithRadius:0.05];
    _moonNode.geometry = [SCNSphere sphereWithRadius:0.01];
    _jupiterNode.geometry = [SCNSphere sphereWithRadius:0.15];
    _saturnNode.geometry = [SCNSphere sphereWithRadius:0.12];
    _uranusNode.geometry = [SCNSphere sphereWithRadius:0.09];
    _neptuneNode.geometry = [SCNSphere sphereWithRadius:0.08];
    _plutoNode.geometry = [SCNSphere sphereWithRadius:0.04];
//    设置月亮的三维坐标
    _moonNode.position = SCNVector3Make(0.1, 0, 0);
//    添加节点
    [_earthGroupNode addChildNode:_earthNode];
    [_sartunGruopNode addChildNode:_saturnNode];
//    添加土星环
    SCNNode *saturnLoopNode = [SCNNode new];
//    设置不透明度
    saturnLoopNode.opacity = 0.4;
//    设置轨道的结构体，height为0
    saturnLoopNode.geometry = [SCNBox boxWithWidth:0.6 height:0 length:0.6 chamferRadius:0];
//    设置贴图
    saturnLoopNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/saturn_loop.png";
//     纹理滤波
    saturnLoopNode.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
//    设置四维坐标
    saturnLoopNode.rotation = SCNVector4Make(-0.5, -1, 0, M_PI_2);
//    光照模式
    saturnLoopNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    [_sartunGruopNode addChildNode:saturnLoopNode];
    
    _mercuryNode.position = SCNVector3Make(0.4, 0, 0);
    _venusNode.position = SCNVector3Make(0.6, 0, 0);
    _earthGroupNode.position = SCNVector3Make(0.8, 0, 0);
    _marsNode.position = SCNVector3Make(1.0, 0, 0);
    _jupiterNode.position = SCNVector3Make(1.4, 0, 0);
    _sartunGruopNode.position = SCNVector3Make(1.68, 0, 0);
    _uranusNode.position = SCNVector3Make(1.95, 0, 0);
    _neptuneNode.position = SCNVector3Make(2.14, 0, 0);
    _plutoNode.position = SCNVector3Make(2.319, 0, 0);
    [_sunNode setPosition:SCNVector3Make(0, -0.1, 3)];
    [scnView.scene.rootNode addChildNode:_sunNode];
    
        //水星贴图
    _mercuryNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/mercury.jpg";
        //金星贴图
    _venusNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/venus.jpg";
        //火星贴图
    _marsNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/mars.jpg";
        // 地球贴图
    _earthNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/earth-diffuse-mini.jpg";
    _earthNode.geometry.firstMaterial.emission.contents = @"art.scnassets/earth/earth-emissive-mini.jpg";
    _earthNode.geometry.firstMaterial.specular.contents = @"art.scnassets/earth/earth-specular-mini.jpg";
        //月球贴图
    _moonNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/moon.jpg";
        //木星贴图
    _jupiterNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/jupiter.jpg";
        //土星贴图
    _saturnNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/saturn.jpg";
    _saturnLoopNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/saturn_loop.jpg";
        //天王星
    _uranusNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/uranus.jpg";
        //海王星
    _neptuneNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/neptune.jpg";
        //冥王星
    _plutoNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/pluto.jpg";
        //太阳贴图
    _sunNode.geometry.firstMaterial.multiply.contents = @"art.scnassets/earth/sun.jpg";
    _sunNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun.jpg";
    _sunNode.geometry.firstMaterial.multiply.intensity = 0.5;
    _sunNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    
    _sunNode.geometry.firstMaterial.multiply.wrapS =
    _sunNode.geometry.firstMaterial.diffuse.wrapS  =
    _sunNode.geometry.firstMaterial.multiply.wrapT =
    _sunNode.geometry.firstMaterial.diffuse.wrapT  = SCNWrapModeRepeat;
    
    _mercuryNode.geometry.firstMaterial.locksAmbientWithDiffuse =
    _venusNode.geometry.firstMaterial.locksAmbientWithDiffuse =
    _marsNode.geometry.firstMaterial.locksAmbientWithDiffuse =
    _earthNode.geometry.firstMaterial.locksAmbientWithDiffuse =
    _moonNode.geometry.firstMaterial.locksAmbientWithDiffuse  =
    _jupiterNode.geometry.firstMaterial.locksAmbientWithDiffuse  =
    _saturnNode.geometry.firstMaterial.locksAmbientWithDiffuse  =
    _uranusNode.geometry.firstMaterial.locksAmbientWithDiffuse  =
    _neptuneNode.geometry.firstMaterial.locksAmbientWithDiffuse  =
    _plutoNode.geometry.firstMaterial.locksAmbientWithDiffuse  =
    _sunNode.geometry.firstMaterial.locksAmbientWithDiffuse   = YES;
    
    _mercuryNode.geometry.firstMaterial.shininess =
    _venusNode.geometry.firstMaterial.shininess =
    _earthNode.geometry.firstMaterial.shininess =
    _moonNode.geometry.firstMaterial.shininess =
    _marsNode.geometry.firstMaterial.shininess =
    _jupiterNode.geometry.firstMaterial.shininess =
    _saturnNode.geometry.firstMaterial.shininess =
    _uranusNode.geometry.firstMaterial.shininess =
    _neptuneNode.geometry.firstMaterial.shininess =
    _plutoNode.geometry.firstMaterial.shininess = 0.1;
    
    _mercuryNode.geometry.firstMaterial.specular.intensity =
    _venusNode.geometry.firstMaterial.specular.intensity =
    _earthNode.geometry.firstMaterial.specular.intensity =
    _moonNode.geometry.firstMaterial.specular.intensity =
    _marsNode.geometry.firstMaterial.specular.intensity =
    _jupiterNode.geometry.firstMaterial.specular.intensity =
    _saturnNode.geometry.firstMaterial.specular.intensity =
    _uranusNode.geometry.firstMaterial.specular.intensity =
    _neptuneNode.geometry.firstMaterial.specular.intensity =
    _plutoNode.geometry.firstMaterial.specular.intensity =
    _marsNode.geometry.firstMaterial.specular.intensity = 0.5;
    _moonNode.geometry.firstMaterial.specular.contents = [UIColor grayColor];
    [self roationNode];
    [self addOtherNode];
    [self addLight];
    
}
-(void)roationNode{
//        earthNode以y轴不停的旋转，每次旋转的周期为1s。
    [_earthNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];        //月球自转
    animation.duration = 1.5;//自转周期1.5s
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];//此处的意思是围绕y轴([0,0,0]->[0,1,0])旋转360°
    animation.repeatCount = FLT_MAX;//重复次数，此处无限次
    [_moonNode addAnimation:animation forKey:@"moon rotation"];//将动画添加至moonNode节点
    
    SCNNode *moonRotationNode = [SCNNode node];
    [moonRotationNode addChildNode:_moonNode];
//同月球一致
    CABasicAnimation *moonRotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moonRotationAnimation.duration = 15.0;
    moonRotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    moonRotationAnimation.repeatCount = FLT_MAX;
    [moonRotationNode addAnimation:animation forKey:@"moon rotation around earth"];
    [_earthGroupNode addChildNode:moonRotationNode];
    
    SCNNode *earthRotationNode = [SCNNode node];
    [_sunNode addChildNode:earthRotationNode];
    [earthRotationNode addChildNode:_earthGroupNode];
    animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 30.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [earthRotationNode addAnimation:animation forKey:@"earth rotation around sun"];
    [_mercuryNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    [_venusNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    [_marsNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    [_jupiterNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    [_saturnNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    [_uranusNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    [_neptuneNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    [_plutoNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    [_sartunGruopNode addChildNode:_saturnNode];
    
    SCNNode *mercRotationNode = [SCNNode node];
    [mercRotationNode addChildNode:_mercuryNode];
    [_sunNode addChildNode:mercRotationNode];
    
    SCNNode *venusRotationNode = [SCNNode node];
    [venusRotationNode addChildNode:_venusNode];
    [_sunNode addChildNode:venusRotationNode];
    
    SCNNode *marsRotationNode = [SCNNode node];
    [marsRotationNode addChildNode:_marsNode];
    [_sunNode addChildNode:marsRotationNode];
    
    SCNNode *jupiterRotationNode = [SCNNode node];
    [jupiterRotationNode addChildNode:_jupiterNode];
    [_sunNode addChildNode:jupiterRotationNode];
    
    SCNNode *saturnRotationNode = [SCNNode node];
    [saturnRotationNode addChildNode:_sartunGruopNode];
    [_sunNode addChildNode:saturnRotationNode];
    
    SCNNode *uranusRotationNode = [SCNNode node];
    [uranusRotationNode addChildNode:_uranusNode];
    [_sunNode addChildNode:uranusRotationNode];
    
    SCNNode *neptuneRotationNode = [SCNNode node];
    [neptuneRotationNode addChildNode:_neptuneNode];
    [_sunNode addChildNode:neptuneRotationNode];
    
    SCNNode *plutoRotationNode = [SCNNode node];
    [plutoRotationNode addChildNode:_plutoNode];
    [_sunNode addChildNode:plutoRotationNode];
    
    animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 25.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [mercRotationNode addAnimation:animation forKey:@"mercury rotation around sun"];
    [_sunNode addChildNode:mercRotationNode];
    
    animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 40.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [venusRotationNode addAnimation:animation forKey:@"venus rotation around sun"];
    [_sunNode addChildNode:venusRotationNode];
    
    animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 35.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [marsRotationNode addAnimation:animation forKey:@"mars rotation around sun"];
    [_sunNode addChildNode:marsRotationNode];
    
    animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 90.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [jupiterRotationNode addAnimation:animation forKey:@"jupiter rotation around sun"];
    [_sunNode addChildNode:jupiterRotationNode];
    
    animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 80.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [saturnRotationNode addAnimation:animation forKey:@"mars rotation around sun"];
    [_sunNode addChildNode:saturnRotationNode];
    
    animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 55.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [uranusRotationNode addAnimation:animation forKey:@"mars rotation around sun"];
    [_sunNode addChildNode:uranusRotationNode];
    
    animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 50.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [neptuneRotationNode addAnimation:animation forKey:@"mars rotation around sun"];
    [_sunNode addChildNode:neptuneRotationNode];
    
    animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = 100.0;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [plutoRotationNode addAnimation:animation forKey:@"mars rotation around sun"];
    [_sunNode addChildNode:plutoRotationNode];
    
    [self addAnimationToSun];
}

-(void)addAnimationToSun{
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    animation.duration = 10.0;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    animation.repeatCount = FLT_MAX;
    [_sunNode.geometry.firstMaterial.diffuse addAnimation:animation forKey:@"sun-texture"];
    animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    animation.duration = 30.0;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(5, 5, 5))];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5))];
    animation.repeatCount = FLT_MAX;
    [_sunNode.geometry.firstMaterial.multiply addAnimation:animation forKey:@"sun-texture2"];
    
}

- (void)addOtherNode{
    SCNNode *cloudsNode = [SCNNode node];
    cloudsNode.geometry = [SCNSphere sphereWithRadius:0.06];
    [_earthNode addChildNode:cloudsNode];
    cloudsNode.opacity = 0.5;

    cloudsNode.geometry.firstMaterial.transparent.contents = @"art.scnassets/earth/cloudsTransparency.png";
    cloudsNode.geometry.firstMaterial.transparencyMode = SCNTransparencyModeRGBZero;
//    为太阳增加光环
    _sunHaloNode = [SCNNode node];
    _sunHaloNode.geometry = [SCNPlane planeWithWidth:2.5 height:2.5];
    _sunHaloNode.rotation = SCNVector4Make(1, 0, 0, 0 * M_PI / 180.0);
    _sunHaloNode.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/sun-halo.png";
    _sunHaloNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    _sunHaloNode.geometry.firstMaterial.writesToDepthBuffer = NO;
    _sunHaloNode.opacity = 0.2;
    [_sunNode addChildNode:_sunHaloNode];
    
    SCNNode *mercuryOrbit = [SCNNode node];
    mercuryOrbit.opacity = 0.4;
    mercuryOrbit.geometry = [SCNBox boxWithWidth:0.86 height:0 length:0.86 chamferRadius:0];
    mercuryOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
    mercuryOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    mercuryOrbit.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    mercuryOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    [_sunNode addChildNode:mercuryOrbit];
    
    SCNNode *venusOrbit = [SCNNode node];
    venusOrbit.opacity = 0.4;
    venusOrbit.geometry = [SCNBox boxWithWidth:1.29 height:0 length:1.29 chamferRadius:0];
    venusOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
    venusOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    venusOrbit.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    venusOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    [_sunNode addChildNode:venusOrbit];
    
    SCNNode *earthOrbit = [SCNNode node];
    earthOrbit.opacity = 0.4;
    earthOrbit.geometry = [SCNBox boxWithWidth:1.72 height:0 length:1.72 chamferRadius:0];
    earthOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
    earthOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    earthOrbit.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    earthOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    [_sunNode addChildNode:earthOrbit];
    
    SCNNode *marsOrbit = [SCNNode node];
    marsOrbit.opacity = 0.4;
    marsOrbit.geometry = [SCNBox boxWithWidth:2.14 height:0 length:2.14 chamferRadius:0];
    marsOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
    marsOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    marsOrbit.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    marsOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    [_sunNode addChildNode:marsOrbit];
    
    SCNNode *jupiterOrbit = [SCNNode node];
    jupiterOrbit.opacity = 0.4;
    jupiterOrbit.geometry = [SCNBox boxWithWidth:2.95 height:0 length:2.95 chamferRadius:0];
    jupiterOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
    jupiterOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    jupiterOrbit.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    jupiterOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    [_sunNode addChildNode:jupiterOrbit];
    
    SCNNode *saturnOrbit = [SCNNode node];
    saturnOrbit.opacity = 0.4;
    saturnOrbit.geometry = [SCNBox boxWithWidth:3.57 height:0 length:3.57 chamferRadius:0];
    saturnOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
    saturnOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    saturnOrbit.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    saturnOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    [_sunNode addChildNode:saturnOrbit];
    
    SCNNode *uranusOrbit = [SCNNode node];
    uranusOrbit.opacity = 0.4;
    uranusOrbit.geometry = [SCNBox boxWithWidth:4.19 height:0 length:4.19 chamferRadius:0];
    uranusOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
    uranusOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    uranusOrbit.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    uranusOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    [_sunNode addChildNode:uranusOrbit];
    
    SCNNode *neptuneOrbit = [SCNNode node];
    neptuneOrbit.opacity = 0.4;
    neptuneOrbit.geometry = [SCNBox boxWithWidth:4.54 height:0 length:4.54 chamferRadius:0];
    neptuneOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
    neptuneOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    neptuneOrbit.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    neptuneOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    [_sunNode addChildNode:neptuneOrbit];
    
    SCNNode *pluteOrbit = [SCNNode node];
    pluteOrbit.opacity = 0.4;
    pluteOrbit.geometry = [SCNBox boxWithWidth:4.98 height:0 length:4.98 chamferRadius:0];
    pluteOrbit.geometry.firstMaterial.diffuse.contents = @"art.scnassets/earth/orbit.png";
    pluteOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    pluteOrbit.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    pluteOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    [_sunNode addChildNode:pluteOrbit];
}

-(void)addLight{
        // We will turn off all the lights in the scene and add a new light
        // to give the impression that the Sun lights the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.color = [UIColor blackColor]; 
    lightNode.light.type = SCNLightTypeOmni;
    [_sunNode addChildNode:lightNode];
    lightNode.light.attenuationEndDistance = 19;
    lightNode.light.attenuationStartDistance = 21;
        // Animation
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1];
    {
    lightNode.light.color = [UIColor whiteColor];
    _sunHaloNode.opacity = 0.5;
    }
    [SCNTransaction commit];
}

- (void)viewWillAppear:(BOOL)animated{
    NSURL *musicURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"pggmusic" ofType:@"mp3"]];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:musicURL];
    self.audioPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    [self.audioPlayer play];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.audioPlayer pause];
    self.audioPlayer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
