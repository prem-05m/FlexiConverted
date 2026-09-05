import os
import glob

files = glob.glob('lib/features/*/presentation/widgets/*_tool_card.dart')
for f in files:
    with open(f, 'r') as file:
        content = file.read()
    
    if 'FavoriteHeartIcon' in content: 
        print(f"Skipping {f} (already updated)")
        continue
    
    print(f'Updating {f}')
    
    # Add imports
    content = content.replace('import \'../../domain/models/', 'import \'../../../favorites/presentation/widgets/favorite_heart_icon.dart\';\nimport \'../../../favorites/domain/models/favorite_tool_model.dart\';\nimport \'../../domain/models/')
    
    # Replace Padding with Stack
    stack_replacement = '''          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column('''
                
    content = content.replace('          child: Padding(\n            padding: const EdgeInsets.all(16.0),\n            child: Column(', stack_replacement)
    
    # Find the toolType name for the heart icon
    feature_name = f.split('\\')[2] if '\\' in f else f.split('/')[2]
    
    end_replacement = f'''              ),
              Positioned(
                top: -8,
                right: -8,
                child: FavoriteHeartIcon(
                  tool: FavoriteToolItem(
                    toolId: '{feature_name}_${{toolType.name}}',
                    title: title,
                    subtitle: description,
                    iconCodePoint: icon.codePoint,
                    colorValue: color.value,
                    route: '/home/{feature_name}/${{toolType.name}}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}
}}'''
    
    content = content.replace('              ],\n            ),\n          ),\n        ),\n      ),\n    );\n  }\n}', end_replacement)
    
    with open(f, 'w') as file:
        file.write(content)
