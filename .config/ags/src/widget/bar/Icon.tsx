import { Accessor, createComputed } from "ags";

export default function Icon(props: { iconName: string | Accessor<string>; size?: number }) {
  const size = props.size ?? 20;

  const file = createComputed(() => {
    const name = props.iconName instanceof Accessor ? props.iconName() : props.iconName;
    return `${SRC}/icons/${name}-symbolic.svg`;
  });

  return <image file={file} pixelSize={size} />;
}