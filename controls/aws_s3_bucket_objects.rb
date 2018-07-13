
control "s3-objects-no-public-access" do
  impact 0.7
  title "Ensure there are no publicly accessible S3 objects"
  desc "Ensure there are no publicly accessible S3 objects"
  tag "nist": ["AC-6", "Rev_4"]
  tag "severity": "high"

  tag "check": "Review your AWS console and note if any S3 bucket objects are set to
                'Public'. If any objects are listed as 'Public', then this is
                a finding."

  tag "fix": "Log into your AWS console and select the S3 buckets section. Select
              the buckets found in your review. For each object in the bucket
              select the permisssions tab for the object and remove
              the Public Access permission."


  aws_s3_buckets.bucket_names.each do |bucket|

    public_objects = []
    
    aws_s3_bucket_objects(bucket).keys.each do |key|
      public_objects << key if aws_s3_bucket_object(bucket_name: bucket, key: key).public?
    end


    public_objects.each do |key|
      describe aws_s3_bucket_object(bucket_name: bucket, key: key) do
        it { should_not be_public } 
      end
    end

    describe "List of public objects in bucket #{bucket}" do
      subject { public_objects }
      it { should be_empty }  
    end if public_objects.empty?

  end

  describe "Control skipped because no S3 buckets were found" do
    skip "This control is skipped since the aws_s3_buckets resource returned an empty bucket list"
  end if aws_s3_buckets.bucket_names.empty?
end
