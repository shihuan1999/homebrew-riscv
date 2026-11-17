# SpacemiT K3 pico (OpenHarmony 6.1) — ROS 2 机器人开发与 Demo 指南

> 面向基于本 tap（`hbrew/riscv`）做机器人开发的客户。
> 所有命令均在 K3 pico（OH 6.1 / musl / riscv64）真机验证（2026-11-17，16/16 用例通过）。

## 1. 包矩阵（brew 一键安装）

| Formula | 版本 | 内容 | 真机验证 |
|---|---|---|---|
| `ros2-humble-full` | 16.0.21 | ROS 2 Humble 核心（rcl/rclcpp/rclpy、demo_nodes、rosbag2、tf2、launch 等） | ✅ DDS/Service/rosbag/tf2/launch |
| `ros2-slam` | 0.2.0 | slam_toolbox 2D 建图 | ✅ 仿真建图出图 |
| `ros2-nav2` | 1.1.20 | Nav2 导航全栈（NavFn/DWB/Smac/MPPI/BT） | ✅ 双控制器导航到点 <0.3m |
| `ros2-sim` | 0.1.0 | robot-sim 差速轮仿真器（无屏也可跑） | ✅ SLAM/Nav2 底座 |
| `ros2-controllers` | 4.15.0 | ros2_control + 10 个控制器 | ✅ mock 硬件 /joint_states 闭环 |
| `spacemit-humanoid-common` | 2026.11.13 | 人形机器人核心库（robot_base / transport_executor / operator_client） | ✅ ELF 可加载 |
| `ros2-spacemit-humanoid` | 2026.11.12 | 人形 cmd_vel 桥、动态 TF、导航 launch | ✅ 桥存活 + /cmd_vel 订阅可见 |
| `ros2-spacemit-linksee` | 2026.09.21 | 轮式底盘（linksee）launch/config + rclpy 节点（odom 重映射、语音） | ✅ odom_remap 节点运行 |
| `ros2-spacemit-examples` | 2026.11.16 | SpacemiT 官方 demo 集（slam_toolbox_run/nav2/humanoid_mujoco 的 launch+config） | ✅ launch/config 可解析 |
| `opencv` | 4.10.0 | OpenCV 4.10 视觉库（core/imgproc/imgcodecs/dnn/calib3d/…，headless musl 交叉构建） | ✅ cv_bridge ELF 链全解析 |
| `ros2-vision` | 2026.11.17 | cv_bridge（C++ 核心）+ image_transport/压缩插件 + image_proc/publisher + vision_msgs | ✅ 6 包可见 + 节点运行 |
| `mujoco` | 3.4.0 | MuJoCo 3.4 物理引擎核心库（headless，含 MJCF 模型资产与头文件） | ✅ musl 加载链全解析 |

安装（依赖自动解）：

```sh
brew install hbrew/riscv/ros2-humble-full
brew install hbrew/riscv/ros2-slam hbrew/riscv/ros2-nav2 hbrew/riscv/ros2-sim hbrew/riscv/ros2-controllers
brew install hbrew/riscv/spacemit-humanoid-common hbrew/riscv/ros2-spacemit-humanoid \
             hbrew/riscv/ros2-spacemit-linksee hbrew/riscv/ros2-spacemit-examples
# P1 视觉 / P2 仿真（可选）
brew install hbrew/riscv/opencv hbrew/riscv/ros2-vision hbrew/riscv/mujoco
```

离线设备（无外网）：按 [CONTRIBUTING.md「离线设备安装」](CONTRIBUTING.md) 用 hdc 预置 bottle 缓存后 `brew install`。

## 2. 环境激活

每个包自带 `<pkg>-env` 脚本；推荐做一个聚合 `brew_env.sh`：

```sh
. /data/harmonybrew/hbrew-env.sh
. /data/harmonybrew/opt/ros2-humble-full/bin/ros2-full-env
. /data/harmonybrew/opt/ros2-slam/bin/ros2-slam-env
. /data/harmonybrew/opt/ros2-nav2/bin/ros2-nav2-env
. /data/harmonybrew/opt/ros2-sim/bin/ros2-sim-env
. /data/harmonybrew/opt/ros2-spacemit-examples/bin/ros2-spacemit-env   # 存在才 source
. /data/harmonybrew/opt/ros2-controllers/bin/ros2-controllers-env
. /data/harmonybrew/opt/ros2-spacemit-humanoid/bin/ros2-spacemit-humanoid-env
. /data/harmonybrew/opt/ros2-spacemit-linksee/bin/ros2-spacemit-linksee-env
export CYCLONEDDS_URI=file:///path/to/cdds.xml        # 可选：DDS 调优
```

之后 `ros2 topic list`、`ros2 run ...`、`ros2 launch ...` 全部可用（python3 由 brew python 提供）。

## 3. 开箱 Demo（全部真机验证过）

### Demo 1 — DDS 通信与 Service RPC
```sh
ros2 run demo_nodes_cpp talker &          # 发布 /chatter
ros2 topic echo /chatter                  # 订阅验证
ros2 run demo_nodes_cpp add_two_ints_server &
ros2 service call /add_two_ints example_interfaces/srv/AddTwoInts "{a: 2, b: 3}"
```

### Demo 2 — rosbag2 录制回放
```sh
ros2 run demo_nodes_cpp talker &
ros2 bag record -o /data/bag1 /chatter    # Ctrl-C 停止
ros2 bag info /data/bag1                  # Messages: N
ros2 bag play /data/bag1
```

### Demo 3 — TF2 链路（URDF → robot_state_publisher → joint_states）
```sh
# 发布关节角（自己的机器人换成你的 joint 名）
python3 -c "
import rclpy, time
from rclpy.node import Node
from sensor_msgs.msg import JointState
rclpy.init(); n=Node('jsp'); p=n.create_publisher(JointState,'/joint_states',10)
t0=time.time()
while time.time()-t0<30:
    m=JointState(); m.name=['j1','j2']; m.position=[0.5,0.25]
    m.header.stamp=n.get_clock().now().to_msg(); p.publish(m); time.sleep(0.2)
" &
ros2 run robot_state_publisher robot_state_publisher /path/to/two_link.urdf
ros2 run tf2_ros tf2_echo link1 link2      # 应打印 Translation/Rotation
```

### Demo 4 — SLAM 建图（robot-sim 仿真底盘，无需实体雷达）
```sh
ros2 launch ros2-sim <sim.launch.py>       # 差速轮仿真 + 激光模拟（详见 ros2-sim-env 后 ros2 pkg list）
ros2 run teleop_twist_keyboard teleop_twist_keyboard   # 控车走几圈
ros2 run nav2_map_server map_saver_cli -f /data/map1   # 存图 map1.pgm + map1.yaml
```

### Demo 5 — Nav2 自主导航（两种控制器实测）
```sh
# 前提：一张地图（/data/ros2-robot/map/brew_map.yaml 可由 Demo 4 生成）
ros2 launch /path/to/nav2_sim.launch.py    # amcl+planner+controller+bt 全栈
ros2 topic pub --once /goal_pose geometry_msgs/msg/PoseStamped \
  "{header: {frame_id: map}, pose: {position: {x: 2.5, y: 0.5}}}"
ros2 topic echo /navigate_to_pose/_action/status   # status=4 即到达
```
实测：NavFn+DWB 误差 0.148m / Smac+MPPI 误差 0.259m（目标 <0.5m）。

### Demo 6 — ros2_control 控制闭环（mock 硬件）
```sh
URDF=$(cat /path/to/mock_bot.urdf)
ros2 run controller_manager ros2_control_node --ros-args \
  -p robot_description:="$URDF" --params-file /path/to/mock_ctrl.yaml &
ros2 run controller_manager spawner joint_state_broadcaster --controller-manager /controller_manager
ros2 topic echo /joint_states --once       # 有关节状态流动
```
换你自己的机器人：改 URDF 的 ros2_control 块（hardware plugin + joints）+ controller yaml。

### Demo 7 — SpacemiT 机器人栈
```sh
# linksee 轮式底盘（odom 重映射节点，等待 TF 属正常设计）
$(brew --prefix)/opt/ros2-spacemit-linksee/lib/linksee/odom_remap_node.py

# 人形机器人 cmd_vel 桥（速度指令 → 整机控制）
ros2 launch ros2_spacemit_humanoid <bridge.launch.py>   # 详见包内 share/

# 官方 examples（slam_toolbox_run / nav2 / humanoid_mujoco 的 launch+config）
ros2 launch ros2_spacemit_examples <xxx.launch.py>
```

## 4. 客户自研机器人接入路径

1. **建模**：写 URDF/xacro（关节、ros2_control 硬件块）。
2. **控制**：controller yaml（joint_state_broadcaster + 差速/关节控制器）；实体硬件实现 `hardware_interface::SystemInterface`，或先用 mock 系统联调。
3. **建图导航**：接 2D 雷达 → slam_toolbox 建图 → Nav2 参数（本 tap 的 `ros2-nav2` 提供 K3 实测参数基线）。
4. **上层业务**：参考 `ros2-spacemit-linksee`（轮式）或 `ros2-spacemit-humanoid`（人形）的节点结构。
5. **交叉编译自己的包**：在编译机上用与 bottle 相同的 musl 工具链 colcon 构建（参考 `builds/*/build.sh` 配方模式），产出打成 bottle 后设备 `brew install`。
6. **回归**：用 `ros2-robot-tests` 套件（16 条 P0 用例，`runner.sh --phase p0`）做冒烟，CI 侧由 tap 的 verify-all 周度兜底。

## 5. 已知限制

- 设备 userland 无 `tr`/`awk`：脚本请用 `sed`/shell 内建/python3 替代。
- `cv_bridge` 以 C++ 核心形态提供（python 绑定需要 Boost.python，musl 未启）——C++ 视觉节点不受影响。
- `mujoco` 为 headless 物理核心（无 GL 渲染）；`mujoco_sim`/`humanoid_mujoco` C++ 节点依赖 X11+gl4es 渲染链，属后续攻坚项（examples 包内已含其 launch/config）。
- brew python 的 `ctypes` 因 libffi 符号问题暂不可用（历史遗留，与 ROS 栈无关）。
- VSLAM/perception 等依赖 MPP+GPU 与预编译 glibc 库的组件不在 musl 移植范围（硬件绑定）。

## 6. 故障排查

- 节点起不来/装不上：`hilog | grep -i brew`；`brew doctor`。
- DDS 发现异常：确认 `ROS_DOMAIN_ID` 一致；大流量场景配置 `CYCLONEDDS_URI`。
- 完整验证方法：`ros2-robot-tests/runner.sh`（16 用例含 SLAM/Nav2/控制/底盘/人形）。
