# Quest Infrastructure 

### AI Disclosure:

I tried to build this with my own two ignorant hands out of spite to myself and my family. It was still assembled by my two (very clumsy) hands but in the age of search engines and gen AI result summaries it's really more of a "You got your chocolate in my peanut butter / You got your peanut butter in my chocolate!" project. I for sure referenced public code from my GitHub which Claude did have a few fingers in. I do not hide any LLM commits, you will see comments containing `#AI-DISCLOSURE` when appropriate. I am not ashamed to say I use Generative AI but if you ask Generative AI it may be ashamed to say it's worked with me. 

### Deployment

This project was built with some DevSecOps basics in mind and leverages GitHub Actions for the Docker and Terraform portions. The workflows for container building perform image and Dockerfile scanning with [Trivy](https://trivy.dev/). I am not doing any quality gating on the image because bumping code dependencies are out of scope for this project. With more time I would have attempted to resolve the node vulnerabilities and made an effort to surface the scans via the GitHub Security tab and Trivy SERIF exports. Workflows for Terraform scan with Checkov but are not gated either. Same note about surfacing results would apply, but I would have had Checkov scan and Terraform plan on PRs and comment the results on the PR vs. blocking the `master` branch. 

#### AWS 

I cobbled together a Terraform module for AWS to handle the following:

- ECS Cluster, Task Definition, and Service Definition creation
- Elastic Load Balancing infrastructure (ALB, Listeners, Target Groups)
- Security Group creation in the Default VPC
- IAM Role and Policy creation
- Secrets Manager Secret for injecting the `SECRET_WORD` variable into the container service.
- ACM validation + CloudFlare DNS TXT Record updating

Did I need to pass the word through Secrets Manager? It's probably overkill but I already spend at least three high end iced coffees on Secret storage in AWS per month so doing it for this workload was trivial. Unfortunately, it's not an AWS deployment if you aren't mapping dependencies like this for even the simplest of workloads:

![Pepe Silvia](./assets/pepe-silvia.png)

So anyway, there I was with my CVS receipt length AWS module to make a total of 8 web requests. If I printed it, would it rival "Crime and Punishment"? No, but like the receipt for a pack of gum one is required to ask "all this...for that?". Truly dear reader, yes - all this, to do just that little. Puts on AWS 📉?

For the AWS module documentation please refer to the  `terraform-docs` [generated documentation](./modules/aws/README.md). If I had more time I would have built out the VPC infrastructure from Terraform, instead I leveraged the default VPC id passed in via `TF_VAR_aws_vpc_id`. 

#### Burning Down Long-Lived Keys

![Hank Scorpio Flamethrower](./assets/hank-scorpio-evil-laughter.gif)

I deleted all long lived AWS key pairs in my personal AWS organization (down with [AWS AKIA keys!](https://docs.aws.amazon.com/STS/latest/APIReference/API_GetAccessKeyInfo.html)) so it seemed silly to not show that off in this project. The Actions workflow that handles Terraform deployment sets up short lived tokens from AWS STS because GitHub Actions' `tokens.actions.githubusercontent.com` is a trusted OIDC provider in my AWS development account. I can have the `aws-actions/configure-aws-credentials@v4` action handle the token exchange and allow Terraform to make calls to the AWS control plane APIs. 

This is not a "security" project per-se but this is table stakes for any secure deployment pipeline. CI/CD is one of the most valuable places for an attacker to get access. By moving what I can to short-lived keys we impose a higher cost on a would-be attacker and every time they come back for a new set of keys there is another opportunity to catch it. 

![Tony Soprano is an American Hero](./assets/asia-tony-soprano.jpg)

You can tell the difference between long lived keys in AWS because they all start with `AKIA` like this: `AKIAIOSFODNN7EXAMPLE`. Short lived keys in AWS start with `ASIA` and look something like this: `ASIAY34FZKBOKMUTVV7`. [Up with AWS ASIA keys!](https://docs.aws.amazon.com/IAM/latest/UserGuide/securing_access-keys.html#Using_access-keys-audit)

#### Azure

I threw together a Terraform module for Azure to handle the following:

- Resource Group creation in East US
- Azure Container App Environment and Container App deployment
- Azure Key Vault for storing the `SECRET_WORD` secret
- Key Vault RBAC Role Assignment for the Container App's SystemAssigned Managed Identity
- Log Analytics Workspace for container logging
- CloudFlare DNS CNAME Record for the Container App FQDN

![I assure you we're open](./assets/unnamed.jpg)

LMAO I am not sure why but the go binaries do not see it running in Azure (I assure you, we're running in Azure). I tried to troubleshoot as best I could but perhaps there is an edge case in how the binaries are trying to hit the IDMS endpoints once being called (I did poke around with `strings` on the binary and think it can't account for Azure Container Apps not exposing an identity metadata service). If I had more time I would swap over to Azure Container Instances just to get all the tests green. 

I performed the same OIDC federation between my personal Entra ID tenant and my GitHub repo for this just as an extra challenge. Shocking that two Microsoft products work well together! I will admit I have less hot takes about Azure: Blue cloud slow! Web interface bad! If money was no object I would have done this on AKS because I am a masochist. I will admit I have a leg up here because I spend many hours yelling at Container App Environments during "the work day" :-)

Claude did help me add a few `az-api` provider resources to help with managed certificate generation. This absolute hack wouldn't be possible without the `azurerm` provider - thanks for the bugs, the hugs, and the missing resources.

For the Azure module documentation please refer to the `terraform-docs` [generated documentation](./modules/azure/README.md).


#### Cloudflare

I've been looking for a reason to play with Cloudflare's new Container runtime. They are my current cloud provider of choice for many things and the $5 paid workers plan are like five of the best dollars I spend every month. Technically it's like 20 bucks because I am Cloudflare Total TLS™️customer (sorry to brag). You'll notice all my `cloudflare` resources feature `proxy=false` because if I proxied everything through Cloudflare and terminated SSL at Cloudflare it wouldn't be very much in the spirit of the exercise. Anyway, 