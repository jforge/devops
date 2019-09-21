import cdk = require('@aws-cdk/core');
import ec2 = require('@aws-cdk/aws-ec2');

export class CdkStackEc2 extends cdk.Stack {
  private addTag(name: string, value: string) {
    cdk.Tag.add(this, name, value);
  };

  private getContext(name: string): string {
    return this.node.tryGetContext(name);
  }

  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const shellCommands = ec2.UserData.forWindows();

    new ec2.CfnInstance(this, 'Instance', {
        imageId: this.getContext("image_id"),
        instanceType: this.getContext("instance_type"),
        keyName: this.getContext("key_pair"),
        networkInterfaces: [
          { deviceIndex: '0', associatePublicIpAddress: true }
        ]
      }
    );

    this.addTag('env', 'prd');
    this.addTag('os', 'windows');
    this.addTag('Name', 'WindowsServer2019');
  }
}