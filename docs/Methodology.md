# Methodology of the H1Linker Project

## The structure of the project folder is as follows:

PATH = /ibex/scratch/projects/c2041/Jeremy/h1linker

``` bash
/h1linker
├── README.md <---- **You are here**
├── data
│   ├── analysis
│   │   └── diff_expression
│   ├── process
│   |	├── alignments
│   │   │   └── First_Milestone
|   │   │       ├── sample1_Align.bam
|   │   │       ├── sample2_Align.bam
|   │   │       └── ...
│   |	└── expression
│   └── raw
│       ├── annotations
│       │   └── index
│       ├── reference
│       │   └── GRCh18.p14
|       │       ├── GRCh18.p14.fna
|       │       ├── GRCh18.p14.gtf
|       │       └── ...
│       └── rnaseq
│           └── First_Milestone
|               ├── sample1
|               │   ├── sample1_1.fastq.gz
|               │   └── sample1_2.fastq.gz
|               ├── sample2
|               │   ├── sample2_1.fastq.gz
|               │   └── sample2_2.fastq.gz
|               └── ...
├── scripts
|	├── preprocessing
|	│   ├── preprocess_task_nextflow1
|	│   ├── preprocess_task_nextflow2 <---- **Next Fastq Preprocessing Flow**
|	│   └── ...
|	├── analysis
|	│   ├── differential_expression.r
|	│   └── ...
|	├── download
|	│   ├── SRAbatch_task_nextflow <---- **Next Batch Download Flow**
|	│   └── ...    
|	└── extra_tools
|    	└── ...
├── results
│   ├── figures
│   ├── fastqc_reports
│   |	└── First_Milestone
│   |       ├── fastqc_raw
|   |       |       ├── sample1_1_fastqc.html
|   |       |       ├── sample1_2_fastqc.html
|   |       |       └── ...
│   |       └── fastqc_trim
|   |               ├── sample1_FP_fastqc.html
|   |               ├── sample1_RP_fastqc.html
|   |               └── ...
│   ├── Nextflow_reports
│   |	├── dag1.html
│   |	├── report1.html
│   |	├── timeline1.html
│   |	└── ...
│   └── tables
│   	├── First_Milestone
│       |   ├── sample1_featureCounts.txt
│       |   ├── sample2_featureCounts.txt
│       |   └── ...
│   	└── ...
└── logs
	├── preprocessing
	│   ├── preprocessing.log
	│   └── ...
	├── analysis
	│   ├── differential_expression.log
	│   └── ...
	├── download
	│   ├── batch_download.log
	│   └── ...    
	└── extra_tools
    	└── ...
```
## Puspose and scope of the Project

Changes in the expression profiles of chromatin-related proteins are thought to play important roles in tumorigeensis. We are particularly interested in linker histones (LHs) as crucial regulators of genome structure and function. There are 11 LH isoforms in human cells and these are known to influence chromatin compaction, DNA accessibility, and gene expression, all key factors in cancer initiation and progression. While the role of LHs in tumorigenesis has been generally recognized (see for example: “Histopathological examination of clinical samples, characterization of the mutational landscape of various types of cancer and functional studies in cancer cell lines have highlighted the linker histone H1 both as a potential biomarker and a driver in cancer.” Scaffidi P. Histone H1 alterations in cancer. Biochim Biophys Acta. 2016 Mar;1859(3):533-9. doi: 10.1016/j.bbagrm.2015.09.008. Epub 2015 Sep 18. PMID: 26386351), the exact biology of the different LH isoforms in this process has not yet been systematically analyzed. 
Proposed Use of Data:
 We are requesting access to your RNA-Seq data to conduct an unbiased analysis using primary cell lines. We will process the RNA-Seq data (FASTQ) using our in-house pipeline for both upstream and downstream analyses. Our primary objective is to identify differential expression patterns in linker histone and linker histone-related genes (DEGs), utilizing tools such as DESeq2 and edgeR within an RStudio environment.
To minimize batch effects and intrinsic variability arising from the use of primary samples and heterogeneous data sources (e.g., studies, laboratories, and public databases), we will increase the number of samples in our analysis. Additionally, we will apply normalization techniques such as RUV and batch effect removal methods like Combat-seq to ensure robust, bias-free results.
We are specifically requesting sequencing data, along with details about the RNA extraction method, and are not interested in sensitive patient information. Since poly-A enriched RNA data does not meet our needs, we are seeking data generated using ribo-depleted total RNA extraction methods.

## Methdological choises

In this section we are going to explain the reason why we used the specific softwares and tools of this project. We will divide this in several parts that will talk about each one of the scripts that we have individually.

One point that I do want to mention is about the use of Nextflow for the construction of most of the scripts used. Nextflow was selected by their compatibility with most of the bioinformatics softwares used during this project and with the hardware infrestructure available in KAUST. Its natural integration with slurm to be able to create singular jobs for each of the samples was key to paralelise the scripts and reduced the amount of time needed to complete the project. The following links were key to design the scripts:

https://nf-co.re/
https://nf-co.re/docs/
https://nf-co.re/events/training

The second important tool that I use is the SRAtoolkit made from NCBI. It is a specific set of tools used to access the data from the NCBI platform, download and process them. The following links contain the documentation of this tool:

https://hpc.nih.gov/apps/sratoolkit.html
https://github.com/ncbi/sra-tools

### Batch Download Scripts

#### Overview

The Next Batch Download Flow is a Nextflow workflow designed to provide an easy-to-use pipeline for downloading raw .fastq files and their metadata using the SRA Toolkit. This results in final .fastq files containing the data and .xml files containing the metadata. The workflow leverages the processing capabilities of an HPC with a SLURM deployment and emphasizes Nextflow's key features: modularity and parallelization.

Currently there are 3 final versions of the Batch Download Scripts:
- SRAbatch_task_nextflow_v3.0a_dbGap
- SRAbatch_task_nextflow_v3.0b_Chernobyl
- SRAbatch_task_nextflow_v3.0c_Open
Each of them correspond to the specific source of the data mentioned in their names.

#### Launch Script

I normally would change the path for the simple error and simple output files to the specific folder where I need it. Most of the time, this depends on which dataset I am analysing the brain or the cancer one. As you see, the script only loads the module for the nextflow which already exist on the HPC. But for the SRAtoolkit I needed to create a specific conda environment that gets activated in the same script before starting the nextflow run. Remember that if you had your script stoped because of time run-out or you had to cancel it with scancel, it is possible to continue the process decomenting the last code line with the -resume flag.

#### Config

The process code block of this script contains how the workflow handdles errors in the processing step (re-tries 3 times the same sample before skipping it completely) and also the profiles or labels for each process with the specific resource allocation. This block is customisable depending on how many resources you can use and need to use to optimize each process.

After this is the params block, this is a very important part of the code as it has the paths for many of the files and directories needed to run the workflow. Here we can find:
- ACCESSION_FILE: Path to the .txt file (See: Preparing the Sample Sheet).
- FINAL_DIR: Path to the final output directory.
- LOG_DIR: Path to the output directory for the logs files.
- NGC_KEY: Path to the .ngc key needed to access db Gap data.

The last block only contains the generation of the dag, report, and timeline .html file that are generated at the end of the run.

#### Main

First, the data that we are obtaining comes mostly from NCBI and db Gap (which is a secured international repository for genomic datasets). For this reason we obted to use SRAtool kit together with Nextflow. Most of the samples from both webpages are compatible with the SREAtoolkit and sometimes it is necessary to used it to be able to download the data. Now, it is important to mention that when using this tool, the format of the data is .sra which is a specific form of compress information that needs to be validated and then process to obtain the actual raw file that you need which would typically be .fastq or .fasta files. In order to do these steps we included the VALIDATE and the FASTERQDUMP processes which uses software included in the SRAtoolkit to run these functions. The FASTERQDUMP process is special in the sense that makes more than just transforming the data from .sra to .fastq format. We saw that not in all of the projects the samples were PAIRED (this means that it has a forward and reverse file that describes the same sample), so in order to take this into consideration we are using the information downloaded in the METADATA processs to be able to detected if it is SINGLE or PAIRED samples and process it according to it.

In order to use the workflow it is necessary to have a simple list with the SRR codes of each of the samples. In the case that you are downloading samples from db Gap you need a .ngc file which contains a unique identifier key that is used to access the data through the SRAtoolkit. 

### Pre-process Scripts

#### Overview

The H1Linker RNA-seq Preprocessing Workflow is a comprehensive Nextflow DSL2 pipeline designed for the preprocessing of raw RNA-seq data. This pipeline performs trimming, alignment, variant calling, contamination estimation, and variant filtering, focusing on identifying H1 Linker gene variants. It is optimized for scalability on HPC systems using SLURM and is structured for modularity and parallelization.

Currently there are 2 final versions of the script:
- preprocess_task_nextflow_v5.0P
- preprocess_task_nextflow_v6.0
The only difference between then is that the v6 has a process that can obtain the somatic mutations of the whole sample. Contrary to the v5.0P that can only obtain the somatic mutations of the specific H1 Linker genes. Other than that, both are the same.

#### Launch Script

The launch script is pretty simple and it only focus on activating the whole main.nf script sending it correctly to ibex through sbatch. The first part load each of the necessary modules that are already implemented on Ibex. Futher, it creates variables that point to the main and config file for the whole nextflow process. Then, it exports 2 different variables to as environment variables that are used in the nextflow code: 
- The timestamp is used on the name of standard output documents produced at the completion of the nextflow process.
- The java memory are used to secure some resources necessary for speeding up the process of the overseer function from nextflow (the overseer is the part of the software that manages the creation of each of the process simultaniously).

The final part of the code is the one that activates the entire nextflow process, there are 2 options:
- start the whole process as new
- resume the process in case it has stop for any reason, to do this it would be necessary that the 'work' folder has not been erased. 

I normally would change the path for the simple error and simple output files to the specific folder where I need it. Most of the time, this depends on which dataset I am analysing the brain or the cancer one. 

#### Config

The process code block of this script contains how the workflow handdles errors in the processing step (re-tries 3 times the same sample before skipping it completely) and also the profiles or labels for each process with the specific resource allocation. This block is customisable depending on how many resources you can use and need to use to optimize each process.

After this is the params block, this is a very important part of the code as it has the paths for many of the files and directories needed to run the workflow. Here we can find:
- input: Path to the .csv file where there is the list of samples ready to be process (check the file example1.csv for more details).
- fai, dict, fasta, gtf, gff: Path to the .fai, .dict , gtf, gff and .fna files containing the human genome assamby GRCh38.p14. This data was obtain from the NCBI page:
  https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001405.40/
- gnomad: Path to the gnomad_merged_fixed.vcf.gz which contains the final merge file of the gnomAD v4.1.0 data set. This contains 76,215 whole genome gene variants, all mapped to the GRCh38 reference sequence. It was download from:
  https://gnomad.broadinstitute.org/downloads
- gnomadindx: path to the .tbi table index file of the gnomad_merged_fixed.vcf.gz file. This file is necessary as allows several tools to peak inside of the merged file. This file was made using the tabix module from Ibex.
- pon, ponin: Path to the Panel-Of-Normals file that is used during the mutect 2 process and its tabix index corresponding file. The data was obtain from the following link:
https://console.cloud.google.com/storage/browser/gatk-best-practices/somatic-hg38;tab=objects?inv=1&invt=AbygbQ&prefix=&forceOnObjectsSortingFiltering=false
- bed, fasta_ref, fai_ref, dict_ref: path to the .fa, .fai, .bed and .dict files that contains the coordinates of the h1linker genes. The .bed file was obtain through the following webpage:
https://genome.ucsc.edu/cgi-bin/hgTables
- LOG_DIR: Path to the output directory for the logs files.
- FASTQC_DIR: Path to the output directory of the .html files with the analysis of the .fastq files.
- index: Path to the STAR idexed files.
- TABLE_DIR: path to the output directory where all the table count matrixes are going to be created.
- VCF_DIR: path to the output directory where all the .vcf files of each sample are going to be created.

An important observation that needs to be done is that most of the files in the params block were modified to contain the common names of the chromosomes instead of the Ensembl name code. 

The last block only contains the generation of the dag, report, and timeline .html file that are generated at the end of the run.

#### Main

The main script is quite large and does several functions. To have a better guide and understanding I would suggest checking the workflow process inside of this script or the dag output file. There are 2 main flows:
- Count matrix: in here we start with the .fastq files as input. Then using fastp and star, we obtain the quality of these .fastq files and their corresponding .bam files. The .bam files are then used to create the count matrix as .txt files that are then used for further analysis.
- VCF: in this flow we start with the .bam files, these are then pass through several pre-processing steps with MarkDuplicates, SplitNCigarReads, AddOrReplaceReadGroups, and samtools index that will prepared them for the 2 processess that obtain the mutations that we are looking for in the h1linker genes. This flow bifurcates into 2 different paths, the variant calling with HaplotypeCaller and the mutect2. With the first one we obtain the germline mutations of our sample, and with the second one we obtain the somatic mutations of our samples. After this, both paths continue through several post-processing steps were we clean the output of possible false positives with CalculateContamination, FilterMutectCalls, VariantFiltration, and bcftools.

### Extra-tools Scripts

#### metadata_fullcode.sh

##### Overview

This script is a utility batch job designed to facilitate the management and preprocessing of RNA-seq sample metadata for the H1Linker project. It is executed on KAUST's Ibex HPC cluster and automates the generation of MD5 checksums, renaming of .xml files, and the execution of multiple Python scripts that process and clean metadata tables. The script is tailored to run on specific dataset batches (e.g., schizophrenia and autism), and its outputs are used as inputs for downstream RNA-seq analysis workflows.

##### Launch Script

The launch script is implemented in Bash and executed via SLURM with a custom resource allocation:
- Job name: MetadataFull
- Resources: 2 nodes, 2 CPUs per task, 24 GB RAM, 5 hours runtime
- Output logs: Directed to /ibex/project/c2041/Jeremy/h1linker/logs/ extra_tools/ with job-specific names
- Email notifications: Sent upon job completion

The script starts by activating a preconfigured conda environment (metadata_env) which includes all dependencies for the Python scripts that follow.

##### Workflow Steps

1. **Directory Setup**
   The script navigates to the specified working directory containing raw `.fastq.gz` and metadata files:

   ```
   /ibex/project/c2041/Jeremy/h1linker/NeuroDegeDiver/data/raw/rnaseq/Third_Milestone/Schizo_Autism/batch4
   ```

2. **MD5 Checksum Generation**

   * All `.fastq.gz` files in the directory are scanned.
   * For each file, its filename, base name (without extension), MD5 checksum, and absolute path are extracted.
   * Results are saved in a tab-delimited format to a file named `md5.stdout`.

3. **Metadata File Conversion**
   If any `.xml` files are present, they are automatically renamed with a `.csv` extension. This prepares them for further parsing and processing by Python scripts.

4. **Python Script Execution**
   Five Python scripts are run sequentially to perform a stepwise metadata cleaning and integration workflow:

   * `Aggregate_metadata.py`: Combines multiple metadata tables into a unified DataFrame.
   * `Duplicate_rows_pandas_csv.py`: Identifies and processes duplicate sample entries.
   * `Merge_md5_metadata.py`: Integrates MD5 checksum data with the sample metadata.
   * `Adding_BlankData.py`: Adds placeholder entries for missing fields to maintain format consistency.
   * `Obtain_data_preprocess.py`: Final formatting and preparation of the metadata table for the Nextflow pipeline.

#### merge_vepall_awk.sh

##### Overview

This utility script is designed to parse and consolidate annotation results from Variant Effect Predictor (VEP) output files into a single summary table. It operates recursively on annotated `.txt` files within a specified output directory and extracts biologically relevant annotation fields for downstream interpretation. The script runs on the Ibex HPC system using SLURM and is optimized to handle large volumes of VEP outputs in an automated fashion. It is mainly used after VEP has been applied to VCF files from RNA-seq variant calling workflows.

##### Launch Script

The script is implemented in Bash and submitted via SLURM with the following specifications:

* **Job name**: `VEP_recursive`
* **Resources**: 2 nodes, 2 CPUs per task, 24 GB RAM, 5-hour runtime
* **Output and error logs**: Stored in `/ibex/project/c2041/Jeremy/h1linker/logs/extra_tools/`
* **Email notification**: Sent upon job completion

All required environment configurations are pre-established and the script is self-contained, requiring no additional conda or module loading for execution.

##### Workflow Steps

1. **Initialization**

   * The path to the directory containing the annotated VEP files is set:

     ```
     /ibex/project/c2041/Jeremy/h1linker/NeuroDegeDiver/results/vcfannotated
     ```
   * A summary output file is defined: `vep_merged_summary.tsv`.
   * If this file exists, it is removed to ensure fresh output for each run.

2. **Iterative Parsing and Merging**

   * The script recursively scans the specified directory for all files ending in `_vep.txt`.
   * For each file:

     * The sample name is derived from the filename (assuming format: `SampleID_vep.txt`).
     * A customized `awk` command parses the file:

       * Skips metadata lines starting with `##`.
       * Extracts standard VEP columns as well as selected annotation fields from the `INFO` field:

         * `IMPACT`
         * `GeneBe_ACMG_classification`
         * `GeneBe_ACMG_criteria`
         * `GeneBe_ACMG_score`
         * `CLNSIG` (ClinVar significance)
         * `CADD_PHRED` (Combined Annotation Dependent Depletion score)
         * `ClinPred` (pathogenicity prediction)
       * These fields are appended as new columns to the output table.
     * The header is added only once, based on the first file processed.

3. **Final Output**

   * All extracted information is merged into a single TSV file:

     ```
     /ibex/project/c2041/Jeremy/h1linker/NeuroDegeDiver/results/vcfannotated/vep_merged_summary.tsv
     ```
   * Each row includes the sample name, original VEP columns, and the selected annotation metrics for easier filtering, plotting, or downstream interpretation.

#### VEP_sbatch2.sh

##### Overview

This script automates the annotation of somatic variant calls using Ensembl’s **Variant Effect Predictor (VEP)** within a **Singularity container** on KAUST’s Ibex HPC cluster. It processes `.vcf.gz` files resulting from Mutect2-based variant calling, annotates them using multiple VEP plugins and custom datasets (e.g., ClinVar, COSMIC), and outputs both text and summary HTML reports. This approach ensures reproducibility, modular plugin usage, and scalability across large VCF datasets.

##### Launch Script

The script is written in Bash and submitted to SLURM with the following configuration:

* **Job name**: `VEP-sbatch_v2`
* **Resources**: 2 nodes, 16 GB RAM per CPU, total wall time of 1 day and 10 hours
* **Output and error logs**: Saved in the `logs/extra_tools/` directory with job- and node-specific names
* **Email notifications**: Sent on job completion

It loads the **Singularity module (v3.9.7)** available on Ibex to ensure container-based reproducibility and isolation from the host environment.

##### Configuration

* **Input Directory**:

  ```
  /ibex/project/c2041/Jeremy/h1linker/NeuroDegeDiver/results/vcf/batch4
  ```

  Contains `.vcf.gz` files to be annotated (output from the variant filtering step).

* **Output Directory**:

  ```
  /ibex/project/c2041/Jeremy/h1linker/NeuroDegeDiver/results/vcfannotated/batch4
  ```

  Stores annotated `.txt` output and `.html` summary files.

* **VEP Cache & Resources**:

  * Uses **local VEP cache** for GRCh38 (`~/.vep`)
  * Includes the following **VEP plugins and datasets**:

    * `CADD` for deleteriousness scoring
    * `ClinPred` for pathogenicity prediction
    * `GeneBe` for ACMG-based variant classification
    * `dbNSFP` for functional annotations across multiple predictors
    * Custom datasets: `ClinVar` (clinical significance) and `COSMIC` (cancer mutations)

All of the plugins and data for them were obtain from the following pages:
https://github.com/Ensembl/ensembl-vep
https://www.ensembl.org/vep

##### Annotation Workflow

1. **Directory Preparation**
   The script ensures the output directory exists and is writable. This avoids permission issues in shared environments.

2. **VCF File Iteration**
   Each file matching `*_mutecpass.vcf.gz` in the input directory is processed. The filename is extracted to generate:

   * A `.txt` output file containing the full VEP annotations
   * An `.html` summary file providing graphical metrics and statistics about the variants

3. **Running VEP via Singularity**
   The core annotation step is performed inside a **Singularity container** to guarantee consistent software and plugin versions. Key options include:

   * `--offline` and `--cache` to avoid remote downloads
   * `--fasta` to specify the human reference genome (GRCh38)
   * Multiple plugins and custom annotations to enrich VEP results with:

     * Pathogenicity scores (`CADD`, `ClinPred`)
     * ACMG classification (`GeneBe`)
     * Functional prediction (`dbNSFP`)
     * Clinical relevance (`ClinVar`, `COSMIC`)
   * `--verbose` and `--force_overwrite` ensure detailed logs and clean output on reruns

4. **Output**
   Each annotated file is saved with a `_vep.txt` suffix alongside a summary report ending in `_summary.html`. All files are stored in the specified output directory.

## Bibliography