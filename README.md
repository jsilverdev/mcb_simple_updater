# Updater for MCB PACKS


## Use

1. Copy the config.example.json for config.json
```console

  cp config.example.json config.json

```

2. Replace the mc_world_path, resource_paths and behavior_paths for the desired paths
```json
{
  "mc_world_path" : "/.../bedrock-server/worlds/your_world",
  "resource_paths" : [
    "/.../resource_pack1"
    "/.../resource_pack2.mcpack"
  ],
  "behavior_paths" : [
    "/.../behavior_pack_1",
    "/.../behavior_pack2.mcaddon"
  ]
}
```

3. Run update.sh
```console

  ./update.sh

```

4. For restore a folder you need the type (mcpack or mcaddon), the uuid, and the version
```console

  ./restore mcpack 00000-0000-00000-0000000000 1.0.0

```